def __main__(_)
  if ARGV.empty?
    raise "Usage: #{$0} comm"
  end

  bpf = CowsnoopBuilder.new(ARGV[0])
  bpf.load
  bpf.attach

  interval = (ARGV[1] || 1).to_i

  map = bpf.counter_map
  map.key_type = Integer
  map.value_type = Integer

  while true
    sleep interval
    puts "[%s] %s" % [Time.now.to_s, map.to_h.inspect]
    map.clear
  end
end
