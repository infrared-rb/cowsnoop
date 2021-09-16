puts "Program #{ARGV.join(' ').inspect} is waiting now to be traced."
puts "Please setup your BPF fantastic tools against:"
puts "  PID = #{$$}"
puts
puts "Then - hit return to continue"
$stdin.gets

exec *ARGV
