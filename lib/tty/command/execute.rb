# encoding: utf-8
# frozen_string_literal: true

require 'tempfile'
require 'securerandom'

module TTY
  class Command
    module Execute
      # Execute command in a child process with all IO streams piped
      # in and out. The interface is similar to Process.spawn
      #
      # The caller should ensure that all IO objects are closed
      # when the child process is finished. However, when block
      # is provided this will be taken care of automatically.
      #
      # @param [Cmd] cmd
      #   the command to spawn
      #
      # @return [pid, stdin, stdout, stderr]
      #
      # @api public
      def spawn(cmd)
        process_opts = normalize_redirect_options(cmd.options)

        # Create pipes
        in_rd,  in_wr  = IO.pipe # reading
        out_rd, out_wr = IO.pipe # writing
        err_rd, err_wr = IO.pipe # error
        in_wr.sync = true

        # redirect fds
        opts = ({
          :in  => in_rd,  in_wr  => :close,
          :out => out_wr, out_rd => :close,
          :err => err_wr, err_rd => :close
        }).merge(process_opts)

        pid = Process.spawn(cmd.to_command, opts)

        # close in parent process
        [in_rd, out_wr, err_wr].each { |fd| fd.close if fd }

        tuple = [pid, in_wr, out_rd, err_rd]

        if block_given?
          begin
            return yield(*tuple)
          ensure
            [in_wr, out_rd, err_rd].each { |fd| fd.close if fd && !fd.closed? }
          end
        else
          tuple
        end
      end

      private

      # Normalize spawn fd into :in, :out, :err keys.
      #
      # @return [Hash]
      #
      # @api private
      def normalize_redirect_options(options)
        options.reduce({}) do |opts, (key, value)|
          if fd?(key)
            _key   = fd_to_process_key(key)
            _value = value

            if _key.to_s == 'in'
              _value = convert_to_fd(value)
            end

            if fd?(value)
              _value = fd_to_process_key(value)
              _value = [:child, _value] # redirect in child process
            end

            opts[_key] = _value
          end
          opts
        end
      end

      # Determine if object is a fd
      #
      # @return [Boolean]
      #
      # @api private
      def fd?(object)
        case object
        when :stdin, :stdout, :stderr, :in, :out, :err,
             STDIN, STDOUT, STDERR, $stdin, $stdout, $stderr, ::IO
          true
        when ::IO
          true
        when ::Integer
          object >= 0
        else
          respond_to?(:to_i) && !object.to_io.nil?
        end
      end

      # Convert fd to name :in, :out, :err
      #
      # @api private
      def fd_to_process_key(object)
        case object
        when STDIN, $stdin, :in, :stdin, 0
          :in
        when STDOUT, $stdout, :out, :stdout, 1
          :out
        when STDERR, $stderr, :err, :stderr, 2
          :err
        when Integer
          object >= 0 ? IO.for_fd(object) : nil
        when IO
          object
        when respond_to?(:to_io)
          object.to_io
        else
          raise ExecuteError, "Wrong execute redirect: #{object.inspect}"
        end
      end

      # Convert file name to file handle
      #
      # @api private
      def convert_to_fd(object)
        return object if fd?(object)

        if object.is_a?(::String) && ::File.exist?(object)
          return object
        end

        tmp = ::Tempfile.new(::SecureRandom.uuid.split('-')[0])
        content = try_reading(object)
        tmp.write(content)
        tmp.rewind
        tmp
      end

      # Attempts to read object content
      #
      # @api private
      def try_reading(object)
        if object.respond_to?(:read)
          object.read
        elsif object.respond_to?(:to_s)
          object.to_s
        else
          object
        end
      end
    end # Execute
  end # Command
end # TTY
