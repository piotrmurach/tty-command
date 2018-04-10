# encoding: utf-8
# frozen_string_literal: true

require 'pastel'

require_relative 'pretty'

module TTY
  class Command
    module Printers
      class PrettyOnError < Pretty
        def print_command_start(cmd, *args)
          super(cmd, *args)

          @out_data = ''
          @err_data = ''
        end

        def print_command_out_data(cmd, *args)
          message = args.map(&:chomp).join(' ')

          @out_data += write("\t#{message}", cmd.uuid, true)
        end

        def print_command_err_data(cmd, *args)
          message = args.map(&:chomp).join(' ')

          @err_data += write("\t" + decorate(message, :red), cmd.uuid, true)
        end

        def print_command_exit(cmd, status, runtime, *args)
          unless status.zero?
            output << @out_data
            output << @err_data
          end

          super(cmd, status, runtime, *args)
        end
      end # PrettyOnError
    end # Printers
  end # Command
end # TTY
