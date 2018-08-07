# frozen_string_literal: true

require_relative '../lib/tty-command'

cmd = TTY::Command.new

out, err = cmd.run("echo 'hello'", :out => :err)

puts "out: #{out}"
puts "err: #{err}"
