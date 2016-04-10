# encoding: utf-8

require 'pastel'

module TTY
  class Command
    class Printer
      extend Forwardable

      def_delegators :@color, :decorate

      # Initialize a Printer object
      #
      # @param [IO] output
      #   the printer output
      #
      # @api public
      def initialize(output)
        @output = output
        @color  = ::Pastel.new(output: output)
      end

      def print_command_start(cmd)
        message = "Running #{decorate(cmd.to_command, :yellow, :bold)}"
        write(message, cmd.uuid)
      end

      def print_command_out_data(uuid, *args)
        message = args.map(&:chomp).join(' ')
        write("\t" + decorate(message, :green), uuid)
      end

      def print_command_err_data(uuid, *args)
        message = args.map(&:chomp).join(' ')
        write("\t" + decorate(message, :red), uuid)
      end

      def print_command_exit(uuid, status, runtime)
        runtime = "%5.3f %s" % [runtime, pluralize(runtime, 'second')]
        message = "Finished in #{runtime}"
        message << " with exit status #{status}" if status
        message << " (#{success_or_failure(status)})"
        write(message, uuid)
      end

      private

      # Pluralize word based on a count
      #
      # @api private
      def pluralize(count, word)
        "#{word}#{'s' unless count.to_f == 1}"
      end

      # @api private
      def success_or_failure(status)
        if status == 0
          decorate('successful', :green, :bold)
        else
          decorate('failed', :red, :bold)
        end
      end

      # Write message out to output
      #
      # @api private
      def write(message, uuid = nil)
        out = uuid.nil? ? '' : "[#{decorate(uuid, :green)}] "
        out << "#{message}"
        @output.puts(out)
      end
    end # Printer
  end # Command
end # TTY
