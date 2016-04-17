# encoding: utf-8

require 'tty/command/execute'
require 'tty/command/result'

module TTY
  class Command
    class ProcessRunner
      include Execute

      # Initialize a Runner object
      #
      # @param [Printer] printer
      #   the printer to use for logging
      #
      # @api private
      def initialize(printer)
        @printer = printer
      end

      # Execute child process
      # @api public
      def run(cmd)
        timeout = cmd.options[:timeout]
        @printer.print_command_start(cmd)
        start = Time.now

        spawn(cmd) do |pid, stdin, stdout, stderr|
          stdout_data, stderr_data = read_streams(cmd, stdout, stderr)

          runtime = Time.now - start
          handle_timeout(timeout, runtime, pid)
          status = waitpid(pid)

          @printer.print_command_exit(cmd, status, runtime)

          Result.new(status, stdout_data, stderr_data)
        end
      end

      private

      # @api private
      def handle_timeout(timeout, runtime, pid)
        return unless timeout

        t = timeout - runtime
        if t < 0.0
          ::Process.kill(:KILL, pid)
        end
      end

      # @api private
      def read_streams(cmd, stdout, stderr)
        stdout_data = ''
        stderr_data = ''
        timeout = cmd.options[:timeout]

        stdout_thread = Thread.new do
          begin
            while (line = stdout.gets)
              stdout_data << line
              @printer.print_command_out_data(cmd, line)
            end
          rescue TimeoutExceeded
            stdout.close
          end
        end

        stderr_thread = Thread.new do
          begin
            while (line = stderr.gets)
              stderr_data << line
              @printer.print_command_err_data(cmd, line)
            end
          rescue TimeoutExceeded
            stderr.close
          end
        end

        [stdout_thread, stderr_thread].each do |th|
          result = th.join(timeout)
          if result.nil?
            stdout_thread.raise(TimeoutExceeded)
            stderr_thread.raise(TimeoutExceeded)
          end
        end
        [stdout_data, stderr_data]
      end

      # @api private
      def waitpid(pid)
        ::Process.waitpid(pid, Process::WUNTRACED)
        $?.exitstatus
      rescue Errno::ECHILD
        # In JRuby, waiting on a finished pid raises.
      end
    end # ProcessRunner
  end # Command
end # TTY
