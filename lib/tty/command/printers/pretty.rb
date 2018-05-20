# encoding: utf-8
# frozen_string_literal: true

require 'pastel'

require_relative 'abstract'

module TTY
  class Command
    module Printers
      class Pretty < Abstract
        TIME_FORMAT = "%5.3f %s".freeze

        def initialize(*)
          super
          @uuid = options.fetch(:uuid) { true }
        end

        def print_command_start(cmd, *args)
          message = ["Running #{decorate(cmd.to_command, :yellow, :bold)}"]
          message << args.map(&:chomp).join(' ') unless args.empty?
          write(cmd, message.join)
        end

        def print_command_out_data(cmd, *args)
          message = args.map(&:chomp).join(' ')
          write(cmd, "\t#{message}", out_data)
        end

        def print_command_err_data(cmd, *args)
          message = args.map(&:chomp).join(' ')
          write(cmd, "\t" + decorate(message, :red), err_data)
        end

        def print_command_exit(cmd, status, runtime, *args)
          if cmd.only_output_on_error && !status.zero?
            output << out_data
            output << err_data
          end

          runtime = TIME_FORMAT % [runtime, pluralize(runtime, 'second')]
          message = ["Finished in #{runtime}"]
          message << " with exit status #{status}" if status
          message << " (#{success_or_failure(status)})"
          write(cmd, message.join)
        end

        # Write message out to output
        #
        # @api private
        def write(cmd, message, data = nil)
          cmd_set_uuid = cmd.options.fetch(:uuid, true)
          uuid_needed = cmd.options[:uuid].nil? ? @uuid : cmd_set_uuid
          out = []
          if uuid_needed
            out << "[#{decorate(cmd.uuid, :green)}] " unless cmd.uuid.nil?
          end
          out << "#{message}\n"
          target = (cmd.only_output_on_error && !data.nil?) ? data : output
          target << out.join
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
      end # Pretty
    end # Printers
  end # Command
end # TTY
