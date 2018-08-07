# frozen_string_literal: true

require_relative '../lib/tty-command'

cli = File.expand_path('cli', __dir__)
cmd = TTY::Command.new

stdin = StringIO.new
stdin.puts "hello"
stdin.puts "world"
stdin.rewind

out, _ = cmd.run(cli, :in => stdin)

puts "#{out}"
