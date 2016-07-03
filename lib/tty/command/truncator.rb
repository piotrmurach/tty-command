# encoding: utf-8

module TTY
  class Command
    # Retains the first N bytes and the last N bytes from written content
    #
    # @api private
    class Truncator
      # Default maximum byte size for prefix & suffix
      DEFAULT_SIZE = 32 << 10

      # Create a Truncator
      #
      # @param [Hash] options
      # @option options [Number] max_size
      #
      # @api public
      def initialize(options = {})
        @max_size = options.fetch(:max_size) { DEFAULT_SIZE }
        @prefix   = ''
        @suffix   = ''
        @skipped  = 0
      end

      # Write content
      #
      # @param [String] content
      #   the content to write
      #
      # @return [nil]
      #
      # @api public
      def write(content)
        content = content.to_s.dup

        content = append(content, @prefix)

        if (over = (content.bytesize - @max_size)) > 0
          content = content[over..-1]
          @skipped += over
        end

        content = append(content, @suffix)

        # suffix is full but we still have content to write
        while content.bytesize > 0
          content = copy(content, @suffix)
        end
      end
      alias_method :<<, :write

      # Truncated representation of the content
      #
      # @return [String]
      #
      # @api public
      def read
        return @prefix if @suffix.empty?

        if @skipped.zero?
          return @prefix << @suffix
        end

        res = ''
        res << @prefix
        res << "\n... omitting #{@skipped} bytes ...\n"
        res << @suffix
        res
      end
      alias_method :to_s, :read

      private

      # Copy minimum bytes from source to destination
      #
      # @return [String]
      #   the remaining content
      #
      # @api private
      def copy(value, dest)
        bytes = value.bytesize
        n = bytes < dest.bytesize ? bytes : dest.bytesize

        head, tail = dest[0...n], dest[n..-1]
        dest.replace("#{tail}#{value[0...n]}")
        @skipped += head.bytesize
        value[n..-1]
      end

      # Append value to destination
      #
      # @param [String] value
      #
      # @param [String] dst
      #
      # @api private
      def append(value, dst)
        remain = @max_size - dst.bytesize
        if remain > 0
          value_bytes = value.to_s.bytesize
          offset = value_bytes < remain ? value_bytes : remain
          dst << value[0...offset]
          value = value[offset..-1]
        end
        value.to_s
      end
    end # Truncator
  end # Command
end # TTY
