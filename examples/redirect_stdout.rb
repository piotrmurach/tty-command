# frozen_string_literal: true

require_relative '../lib/tty-command'

cmd = TTY::Command.new

out, err = cmd.run(:ls, :out => 'ls.log')

puts "OUT>> #{out}"
puts "ERR>> #{err}"
