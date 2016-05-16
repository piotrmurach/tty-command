# encoding: utf-8

require 'tty/command/printers/abstract'

module TTY
  class Command
    module Printers
      class Quiet < Abstract
        attr_reader :output, :options

        def print_command_start(cmd)
          # quiet
        end

        def print_command_exit(cmd, *args)
          # quiet
        end

        def write(message)
          output.print(message)
        end
      end # Progress
    end # Printers
  end # Command
end # TTY
