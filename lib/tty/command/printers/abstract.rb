# encoding: utf-8

require 'pastel'

module TTY
  class Command
    module Printers
    class Abstract
      extend Forwardable

      def_delegators :@color, :decorate

      # Initialize a Printer object
      #
      # @param [IO] output
      #   the printer output
      #
      # @api public
      def initialize(output, options = {})
        @output = output
        enabled = options.fetch(:color) { true }
        @color  = ::Pastel.new(output: output, enabled: enabled)
      end

      def print_command_start(cmd)
        write(cmd.to_command)
      end

      def print_command_out_data(uuid, *args)
        write(args.join)
      end

      def print_command_err_data(uuid, *args)
        write(args.join)
      end

      def print_command_exit(uuid, status, runtime)
        write(status, runtime)
      end

      def write(message, uuid = nil)
        raise NotImplemented, "Abstract printer cannot be used"
      end
    end # Abstract
    end
  end # Command
end # TTY
