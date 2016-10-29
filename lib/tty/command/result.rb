# encoding: utf-8

module TTY
  class Command
    # Encapsulates the information on the command executed
    #
    # @api public
    class Result
      def initialize(status, out, err)
        @status = status
        @out    = out
        @err    = err
      end

      # All data written out to process's stdout stream
      def out
        @out
      end
      alias :stdout :out

      # All data written out to process's stdin stream
      def err
        @err
      end
      alias :stderr :err

      # Information on how the process exited
      #
      # @api public
      def exit_status
        @status
      end
      alias :exitstatus :exit_status
      alias :status :exit_status

      def to_i
        @status
      end

      def to_s
        @status.to_s
      end

      def to_ary
        [@out, @err]
      end

      def exited?
        @status != nil
      end
      alias :complete? :exited?

      def success?
        if exited?
          @status == 0
        else
          false
        end
      end

      def failure?
        !success?
      end
      alias :failed? :failure?

      def ==(other)
        return false unless other.is_a?(TTY::Command::Result)
        @status == other.to_i && to_ary == other.to_ary
      end
    end # Result
  end # Command
end # TTY
