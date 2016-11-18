# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

stdin = StringIO.new
stdin.puts "dupa"
stdin.puts "wolowa"
stdin.rewind

out, _ = cmd.run(:cat, :in => stdin)

puts "#{out}"
