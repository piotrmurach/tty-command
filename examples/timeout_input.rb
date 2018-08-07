# frozen_string_literal: true

require_relative '../lib/tty-command'

cmd = TTY::Command.new

path = File.expand_path("../spec/fixtures/infinite_input", __dir__)

range = 1..Float::INFINITY
infinite_input = range.lazy.map { |x| x }.first(10_000).join("\n")

cmd.run(path, input: infinite_input, timeout: 2)
