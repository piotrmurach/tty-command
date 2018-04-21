# encoding: utf-8

require_relative 'abstract'

module TTY
  class Command
    module Printers
      class Quiet < Abstract
        attr_reader :output, :options

        def print_command_start(cmd)
          # quiet
        end

        def print_command_out_data(cmd, *args)
          write(cmd, args.join(' '), out_data)
        end

        def print_command_err_data(cmd, *args)
          write(cmd, args.join(' '), err_data)
        end

        def print_command_exit(cmd, status, *args)
          unless !cmd.only_output_on_error || status.zero?
            output << out_data
            output << err_data
          end

          # quiet
        end

        def write(cmd, message, data = nil)
          target = (cmd.only_output_on_error && !data.nil?) ? data : output
          target << message
        end
      end # Progress
    end # Printers
  end # Command
end # TTY
