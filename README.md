# cowsnoop   [![Build Status](https://travis-ci.org/udzura/cowsnoop.svg?branch=master)](https://travis-ci.org/udzura/cowsnoop)
Cowsnoop class
## install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'udzura/cowsnoop'
end
```
## example
```ruby
p Cowsnoop.hi
#=> "hi!!"
t = Cowsnoop.new "hello"
p t.hello
#=> "hello"
p t.bye
#=> "hello bye"
```

## License
under the MIT License:
- see LICENSE file
