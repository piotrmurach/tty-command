# frozen_string_literal: true

require_relative '../lib/tty-command'

cmd = TTY::Command.new

begin
  cmd.run("while test 1; do echo 'hello'; sleep 1; done", timeout: 5, signal: :KILL)
rescue TTY::Command::TimeoutExceeded
  puts 'BOOM!'
end
