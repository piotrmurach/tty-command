# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

stdin = StringIO.new
stdin.puts "hello"
stdin.puts "world"
stdin.rewind

out, _ = cmd.run(:cat, :in => stdin)

puts "#{out}"
