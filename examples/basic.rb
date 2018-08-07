# frozen_string_literal: true

require_relative '../lib/tty-command'

cmd = TTY::Command.new

out, err = cmd.run(:echo, 'hello world!')

puts "Result: #{out}"
