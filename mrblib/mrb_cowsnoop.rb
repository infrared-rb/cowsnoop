def __main__(_)
  opt = {}

  parser = OptionParser.new
  parser.on('-c COMM', String) {|comm| opt[:comm] = comm }
  parser.on('-i INTERVAL', Integer) {|int| opt[:interval] = int }
  parser.on('--track-first-clone TARGET_PID', Integer) {|t| opt[:first_clone] = t }
  parser.on('-h') { puts parser.help; exit(1) }
  parser.parse!(ARGV)

  bpf = CowsnoopBuilder.new(opt[:comm] || "")

  if opt[:first_clone]
    bpf.parent_pid = opt[:first_clone]
  end

  bpf.load
  bpf.attach

  interval = opt[:interval] || 1

  map = bpf.counter_map
  map.key_type = Integer
  map.value_type = Integer

  running = true
  Signal.trap(:INT) {
    running = false
  }

  if opt[:first_clone]
  puts "Tracking first forked child."
    while running
      track_first_child(map)
      sleep interval
    end
  else
    while running
      track_any(map)
      sleep interval
    end
  end

  puts "Finishing..."
end

def track_any(map)
  puts "[%s] %s" % [Time.now.to_s, map.to_h.inspect]
  map.clear
end

def track_first_child(map)
  value = nil

  if @target_child
    value = map[@target_child] || 0
  else
    if map_ = map.to_h.first
      @target_child ||= map_[0]
      puts "[!] Tracking: child pid = #{@target_child}"
      value = map_[1]
    end
  end

  if value
    len = [value, 64].min
    puts "[%s] %3d: %s" % [Time.now, value, '@' * len]
  end

  map.clear
end
