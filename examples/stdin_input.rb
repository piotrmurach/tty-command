# encoding: utf-8

require 'tty-command'
require 'pathname'

cmd = TTY::Command.new
cli = Pathname.new('examples/cli.rb')
out, _ = cmd.run(cli, data: "Piotr\n")

puts "#{out}"
