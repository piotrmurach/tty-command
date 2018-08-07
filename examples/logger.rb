# frozen_string_literal: true

require 'logger'
require_relative '../lib/tty-command'

logger = Logger.new('dev.log')

cmd = TTY::Command.new(output: logger, color: false)

cmd.run(:ls)
