# frozen_string_literal: true

require 'logger'
require_relative '../lib/tty-command'

logger = Logger.new('dev.log')
cmd = TTY::Command.new

Thread.new do
  10.times do |i|
    sleep 1
    if i == 5
      logger << "error\n"
    else
      logger << "hello #{i}\n"
    end
  end
end


cmd.wait('tail -f dev.log', /error/)
