# frozen_string_literal: true

require_relative '../lib/tty-command'

cmd = TTY::Command.new

f = 'file'
if cmd.test("[ -f #{f} ]")
  puts "#{f} already exists!"
else
  cmd.run :touch, f
end
