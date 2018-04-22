# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

out, err = cmd.run("env | grep FOO", env: { 'FOO' =>'hello'})

puts "Result: #{out}"
