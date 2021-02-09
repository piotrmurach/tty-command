# frozen_string_literal: true

require_relative "../lib/tty-command"

cmd = TTY::Command.new(pty: true)
cmd.run("rubocop")
