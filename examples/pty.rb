# frozen_string_literal: true

require_relative '../lib/tty-command'

cmd = TTY::Command.new

path = File.expand_path("../spec/fixtures/color", __dir__)

cmd.run(path, pty: true)
