# encoding: utf-8

require 'pastel'
require 'tty/command/printers/abstract'

module TTY
  class Command
    module Printers
      class Progress < Abstract

        def print_command_exit(cmd, status)
          output.print(success_or_failure(status))
        end

        def write(*)
        end

        private

        # @api private
        def success_or_failure(status)
          if status == 0
            decorate('.', :green)
          else
            decorate('F', :red)
          end
        end
      end # Progress
    end # Printers
  end # Command
end # TTY
