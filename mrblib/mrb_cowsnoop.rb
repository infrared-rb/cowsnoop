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

  while running
    puts "[%s] %s" % [Time.now.to_s, map.to_h.inspect]
    map.clear
    sleep interval
  end

  puts "Exitting..."
end
