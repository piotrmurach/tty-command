# frozen_string_literal: true

require 'pathname'
require_relative '../lib/tty-command'

cmd = TTY::Command.new
cli = Pathname.new('examples/cli')
out, _ = cmd.run(cli, input: "Piotr\n")

puts "#{out}"
