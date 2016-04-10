# encoding: utf-8

require 'tempfile'
require 'securerandom'

module TTY
  class Command
    module Execute
      extend self

      # Execute command in a child process
      #
      # The caller should ensure that all IO objects are closed
      # when the child process is finished. However, when block
      # is provided this will be taken care of automatically.
      #
      # @param [Cmd] cmd
      #   the command to execute
      #
      # @return [pid, stdin, stdout, stderr]
      #
      # @api public
      def spawn(cmd)
        @process_options = normalize_redirect_options(cmd.options)

        # Create pipes
        in_rd,  in_wr  = IO.pipe # reading
        out_rd, out_wr = IO.pipe # writing
        err_rd, err_wr = IO.pipe # error

        # redirect fds
        opts = ({
          :in  => in_rd,  in_wr  => :close,
          :out => out_wr, out_rd => :close,
          :err => err_wr, err_rd => :close
        }).merge(@process_options)

        # puts "PROCES OPS>>> #{opts}"
        pid = Process.spawn(cmd.to_command, opts)

        # close in parent process
        [out_wr, err_wr].each { |fd| fd.close if fd }

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

      def normalize_redirect_options(options)
        options.reduce({}) do |opts, (key, value)|
          if fd?(key)
            process_key = fd_to_process_key(key)
            if process_key.to_s == 'in'
              value = convert_to_fd(value)
            end
            opts[process_key]= value
          end
          opts
        end
      end

      # @api private
      def fd?(object)
        case object
        when :stdin, :stdout, :stderr, :in, :out, :err
          true
        when STDIN, STDOUT, STDERR, $stdin, $stdout, $stderr, ::IO
          true
        when ::IO
          true
        when ::Fixnum
          object >= 0
        when respond_to?(:to_i) && !object.to_io.nil?
          true
        else
          false
        end
      end

      def try_reading(object)
        if object.respond_to?(:read)
          object.read
        elsif object.respond_to?(:to_s)
          object.to_s
        else
          object
        end
      end

      def convert_to_fd(object)
        return object if fd?(object)

        if object.is_a?(::String) && File.exists?(object)
          return object
        end

        tmp = Tempfile.new(SecureRandom.uuid.split('-')[0])

        content = try_reading(object)
        tmp.write(content)
        tmp.rewind
        tmp
      end

      def fd_to_process_key(object)
        case object
        when STDIN, $stdin, :in, :stdin, 0
          :in
        when STDOUT, $stdout, :out, :stdout, 1
          :out
        when STDERR, $stderr, :err, :stderr, 2
          :err
        when Fixnum
          object >= 0 ? IO.for_fd(object) : nil
        when IO
          object
        when respond_to?(:to_io)
          object.to_io
        else
          raise ExecuteError, "Wrong execute redirect: #{object.inspect}"
        end
      end
    end # Execute
  end # Command
end # TTY
