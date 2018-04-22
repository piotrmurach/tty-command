# encoding: utf-8

require 'tty-command'

cli = File.expand_path('cli', __dir__)
cmd = TTY::Command.new

stdin = StringIO.new
stdin.puts "hello"
stdin.puts "world"
stdin.rewind

out, _ = cmd.run(cli, :in => stdin)

puts "#{out}"
