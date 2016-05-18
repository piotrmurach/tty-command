# encoding: utf-8

module TTY
  class Command
    class DryRunner
      def initialize(printer)
        @printer = printer
      end

      def run(cmd)
        cmd.to_command
        message = "#{@printer.decorate('(dry run)', :blue)} "
        message << @printer.decorate(cmd.to_command, :yellow, :bold)
        @printer.write(message, cmd.uuid)
        Result.new(0, '', '')
      end
    end # DryRunner
  end # Command
end # TTY
