# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

out, err = cmd.execute(:echo, "$FOO", env: { foo: 'hello'})

puts "Result: #{out}"
