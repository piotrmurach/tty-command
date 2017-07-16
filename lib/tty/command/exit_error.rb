# encoding: utf-8

module TTY
  class Command
    # An ExitError reports an unsuccessful exit by command.
    #
    # The error message includes:
    #  * the name of command executed
    #  * the exit status
    #  * stdout bytes
    #  * stderr bytes
    #
    # @api private
    class ExitError < RuntimeError
      def initialize(cmd_name, result)
        super(info(cmd_name, result))
      end

      def info(cmd_name, result)
        message = ''
        message << "Running `#{cmd_name}` failed with\n"
        message << "  exit status: #{result.exit_status}\n"
        message << "  stdout: #{(result.out || '').strip.empty? ? 'Nothing written' : result.out.strip}\n"
        message << "  stderr: #{(result.err || '').strip.empty? ? 'Nothing written' : result.err.strip}\n"
      end
    end # ExitError
  end # Command
end # TTY
