##
## Cowsnoop Test
##

assert("Cowsnoop#hello") do
  t = Cowsnoop.new "hello"
  assert_equal("hello", t.hello)
end

assert("Cowsnoop#bye") do
  t = Cowsnoop.new "hello"
  assert_equal("hello bye", t.bye)
end

assert("Cowsnoop.hi") do
  assert_equal("hi!!", Cowsnoop.hi)
end
