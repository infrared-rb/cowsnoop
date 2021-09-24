puts "Current pid: #{$$} / Hit key to continue"
gets

$a = [];
p Process.waitpid(fork do
  puts $$
  loop do
    $a << Hash.new
    sleep 0.0001
  end
end)
