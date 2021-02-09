# frozen_string_literal: true

require_relative "../lib/tty-command"

cmd = TTY::Command.new

out, = cmd.run("env | grep FOO", env: { "FOO" => "hello" })

puts "Result: #{out}"
