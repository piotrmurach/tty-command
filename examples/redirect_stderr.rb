# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

out, err = cmd.execute("echo 'hello' 1>& 2")

puts "out: #{out}"
puts "err: #{err}"
