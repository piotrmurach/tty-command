# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

out, err = cmd.run("echo 'hello' 1>& 2")

puts "out: #{out}"
puts "err: #{err}"
