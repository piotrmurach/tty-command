# encoding: utf-8

require 'tty/command/printers/abstract'

module TTY
  class Command
    module Printers
      class Null < Abstract
        def write(*)
          # Do nothing
        end
      end # Null
    end # Printers
  end # Command
end # TTY
