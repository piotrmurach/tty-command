# encoding: utf-8
# frozen_string_literal: true

require 'thread'

require_relative 'child_process'
require_relative 'result'
require_relative 'truncator'

module TTY
  class Command
    class ProcessRunner
      # the command to be spawned
      attr_reader :cmd

      # Initialize a Runner object
      #
      # @param [Printer] printer
      #   the printer to use for logging
      #
      # @api private
      def initialize(cmd, printer, &block)
        @cmd     = cmd
        @timeout = cmd.options[:timeout]
        @input   = cmd.options[:input]
        @signal  = cmd.options[:signal] || "SIGKILL"
        @binmode = cmd.options[:binmode]
        @pty     = cmd.options[:pty] || false
        @printer = printer
        @block   = block

        @pty = TTY::Command.try_loading_pty if @pty
        require('pty') if @pty
      end

      # Execute child process
      #
      # Write the input if provided to the child's stdin and read
      # the contents of both the stdout and stderr.
      #
      # If a block is provided then yield the stdout and stderr content
      # as its being read.
      #
      # @api public
      def run!
        @printer.print_command_start(cmd)
        start = Time.now

        @pid, stdin, stdout, stderr = ChildProcess.spawn(cmd)

        # no input to write, close child's stdin pipe
        stdin.close if (@input.nil? || @input.empty?) && !stdin.nil?

        writers = [@input && stdin].compact

        while writers.any?
          ready = IO.select(nil, writers, writers, @timeout)
          raise TimeoutExceeded if ready.nil?

          write_stream(ready[1], writers)
        end

        stdout_data, stderr_data = read_streams(stdout, stderr)

        puts "WAITING FOR PID: #{@pid}"
        status = waitpid(@pid)
        runtime = Time.now - start

        @printer.print_command_exit(cmd, status, runtime)

        Result.new(status, stdout_data, stderr_data, runtime)
      ensure
        [stdin, stdout, stderr].each { |fd| fd.close if fd && !fd.closed? }
        if @pid # Ensure no zombie processes
          ::Process.detach(@pid)
          terminate(@pid)
        end
      end

      # Stop a process marked by pid
      #
      # @param [Integer] pid
      #
      # @api public
      def terminate(pid)
        ::Process.kill(@signal, pid) rescue nil
      end

      private

      # The buffer size for reading stdout and stderr
      BUFSIZE = 3 * 1024

      # @api private
      def handle_timeout(runtime)
        return unless @timeout

        t = @timeout - runtime
        raise TimeoutExceeded if t < 0.0
      end

      # Write the input to the process stdin
      #
      # @api private
      def write_stream(ready_writers, writers)
        start = Time.now
        ready_writers.each do |fd|
          begin
            err   = nil
            size  = fd.write(@input)
            @input = @input.byteslice(size..-1)
          rescue IO::WaitWritable
          rescue Errno::EPIPE => err
            # The pipe closed before all input written
            # Probably process exited prematurely
            fd.close
            writers.delete(fd)
          end
          if err || @input.bytesize == 0
            fd.close
            writers.delete(fd)
          end

          # control total time spent writing
          runtime = Time.now - start
          handle_timeout(runtime)
        end
      end

      # Read stdout & stderr streams in the background
      #
      # @param [IO] stdout
      # @param [IO] stderr
      #
      # @api private
      def read_streams(stdout, stderr)
        stdout_data = []
        stderr_data = Truncator.new

        out_buffer = ->(line) {
          stdout_data << line
          @printer.print_command_out_data(cmd, line)
          @block.(line, nil) if @block
        }

        err_buffer = ->(line) {
          stderr_data << line
          @printer.print_command_err_data(cmd, line)
          @block.(nil, line) if @block
        }

        stdout_thread = read_stream(stdout, out_buffer)
        stderr_thread = read_stream(stderr, err_buffer)

        stdout_thread.join
        stderr_thread.join

        encoding = @binmode ? Encoding::BINARY : Encoding::UTF_8

        [
          stdout_data.join.force_encoding(encoding),
          stderr_data.read.dup.force_encoding(encoding)
        ]
      end

      def read_stream(stream, buffer)
        Thread.new do
          Thread.current[:cmd_start] = Time.now
          readers = [stream]

          while readers.any?
            puts "SELECTING READER #{readers.inspect}"
            ready = IO.select(readers, nil, readers, @timeout)
            raise TimeoutExceeded if ready.nil?

            puts "READY: #{ready[0].inspect}"

            ready[0].each do |reader|
              begin
                line = reader.readpartial(BUFSIZE)
                puts "BUFFER #{line.inspect}"
                buffer.(line)

                # control total time spent reading
                runtime = Time.now - Thread.current[:cmd_start]
                handle_timeout(runtime)
              rescue Errno::EAGAIN, Errno::EINTR
              rescue EOFError, Errno::EPIPE, Errno::EIO
                readers.delete(reader)
                reader.close
              end

              unless alive?(@pid)
                readers.delete(reader)
                reader.close
              end
            end
          end
          puts "READER THREAD DEAD!"
        end
      end

      def alive?(pid)
        !!Process.kill(0, pid) rescue false
      end

      # @api private
      def waitpid(pid)
        if @pty
          status = PTY.check(pid)
          status.exitstatus if status
        else
          _pid, status = ::Process.waitpid2(pid, ::Process::WUNTRACED)
          status.exitstatus || status.termsig if _pid
        end
      rescue Errno::ECHILD
        # In JRuby, waiting on a finished pid raises.
      end
    end # ProcessRunner
  end # Command
end # TTY
