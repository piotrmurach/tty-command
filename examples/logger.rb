# frozen_string_literal: true

require "logger"
require_relative "../lib/tty-command"

logger = Logger.new("dev.log")
logger.level = Logger::WARN
logger.warn("Logger captured:")

cmd = TTY::Command.new(output: logger, color: false)

cmd.run(:ls)
