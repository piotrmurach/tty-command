# encoding: utf-8

require 'thread'

require_relative 'execute'
require_relative 'result'
require_relative 'truncator'

module TTY
  class Command
    class ProcessRunner
      include Execute

      # the command to be spawned
      attr_reader :cmd

      # Initialize a Runner object
      #
      # @param [Printer] printer
      #   the printer to use for logging
      #
      # @api private
      def initialize(cmd, printer)
        @cmd     = cmd
        @timeout = cmd.options[:timeout]
        @input   = cmd.options[:input]
        @printer = printer
      end

      # Execute child process
      # @api public
      def run!(&block)
        @printer.print_command_start(cmd)
        start = Time.now

        spawn(cmd) do |pid, stdin, stdout, stderr|
          write_stream(stdin)
          stdout_data, stderr_data = read_streams(stdout, stderr, &block)

          runtime = Time.now - start
          handle_timeout(runtime, pid)
          status = waitpid(pid)

          @printer.print_command_exit(cmd, status, runtime)

          Result.new(status, stdout_data, stderr_data)
        end
      end

      # Stop a process marked by pid
      #
      # @param [Integer] pid
      #
      # @api public
      def terminate(pid)
        signal = cmd.options[:signal] || :TERM
        ::Process.kill(signal, pid)
      end

      private

      # @api private
      def handle_timeout(runtime, pid)
        return unless @timeout

        t = @timeout - runtime
        if t < 0.0
          terminate(pid)
        end
      end

      # @api private
      def write_stream(stdin)
        return unless @input
        writers = [stdin]

        # wait when ready for writing to pipe
        _, writable = IO.select(nil, writers, writers, @timeout)
        return if writable.nil?

        while writers.any?
          writable.each do |fd|
            begin
              err   = nil
              size  = fd.write(@input)
              @input = @input.byteslice(size..-1)
            rescue Errno::EPIPE => err
            end
            if err || @input.bytesize == 0
              writers.delete(stdin)
            end
          end
        end
      end

      # Read stdout & stderr streams in the background
      #
      # @param [IO] stdout
      # @param [IO] stderr
      #
      # @api private
      def read_streams(stdout, stderr, &block)
        stdout_data = ''
        stderr_data = Truncator.new

        stdout_yield = -> (line) { block.(line, nil) }
        stderr_yield = -> (line) { block.(nil, line) }

        stdout_thread = Thread.new do
          begin
            while (line = stdout.gets)
              stdout_data << line
              stdout_yield.call(line) if block
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
              stderr_yield.call(line) if block
              @printer.print_command_err_data(cmd, line)
            end
          rescue TimeoutExceeded
            stderr.close
          end
        end

        [stdout_thread, stderr_thread].each do |th|
          result = th.join(@timeout)
          if result.nil?
            stdout_thread.raise(TimeoutExceeded)
            stderr_thread.raise(TimeoutExceeded)
          end
        end
        [stdout_data, stderr_data.read]
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
