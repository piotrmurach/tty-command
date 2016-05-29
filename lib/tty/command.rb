# encoding: utf-8

require 'thread'
require 'tty/command/version'
require 'tty/command/cmd'
require 'tty/command/exit_error'
require 'tty/command/dry_runner'
require 'tty/command/process_runner'
require 'tty/command/printers/null'
require 'tty/command/printers/pretty'
require 'tty/command/printers/progress'
require 'tty/command/printers/quiet'

module TTY
  class Command
    ExecuteError = Class.new(StandardError)

    TimeoutExceeded = Class.new(StandardError)

    attr_reader :printer

    # Initialize a Command object
    #
    # @param [Hash] options
    # @option options [IO] :output
    #   the stream to which printer prints, defaults to stdout
    # @option options [Symbol] :printer
    #   the printer to use for output logging, defaults to :pretty
    # @option options [Symbol] :dry_run
    #   the mode for executing command
    #
    # @api public
    def initialize(options = {})
      @output = options.fetch(:output) { $stdout }
      @color   = options.fetch(:color) { true }
      @uuid    = options.fetch(:uuid) { true }
      @printer_name = options.fetch(:printer) { :pretty }
      @dry_run = options.fetch(:dry_run) { false }
      @printer = use_printer(@printer_name, color: @color, uuid: @uuid)
    end

    # Start external executable in a child process
    #
    # @example
    #   cmd.run(command, [argv1, ..., argvN], [options])
    #
    # @param [String] command
    #   the command to run
    #
    # @param [Array[String]] argv
    #   an array of string arguments
    #
    # @param [Hash] options
    #   hash of operations to perform
    #
    # @option options [String] :chdir
    #   The current directory.
    #
    # @option options [Integer] :timeout
    #   Maximum number of seconds to allow the process
    #   to run before aborting with a TimeoutExceeded
    #   exception.
    #
    # @raise [ExitError]
    #   raised when command exits with non-zero code
    #
    # @api public
    def run(*args)
      cmd = command(*args)
      yield(cmd) if block_given?
      result = execute_command(cmd)
      if result && result.failure?
        raise ExitError.new(cmd.to_command, result)
      end
      result
    end

    # Start external executable without raising ExitError
    #
    # @example
    #   cmd.run!(command, [argv1, ..., argvN], [options])
    #
    # @api public
    def run!(*args)
      cmd = command(*args)
      yield(cmd) if block_given?
      execute_command(cmd)
    end

    # Execute shell test command
    #
    # @api public
    def test(*args)
      run!(:test, *args).success?
    end

    # Check if in dry mode
    #
    # @return [Boolean]
    #
    # @public
    def dry_run?
      @dry_run
    end

    def printer
      use_printer(@printer_name, color: @color, uuid: @uuid)
    end

    private

    # @api private
    def command(*args)
      Cmd.new(*args)
    end

    # @api private
    def execute_command(cmd)
      mutex = Mutex.new
      dry_run = @dry_run || cmd.options[:dry_run] || false
      @runner = select_runner(@printer, dry_run)
      mutex.synchronize { @runner.run(cmd) }
    end

    # @api private
    def use_printer(class_or_name, options)
      if class_or_name.is_a?(TTY::Command::Printers::Abstract)
        return class_or_name
      end

      if class_or_name.is_a?(Class)
        class_or_name
      else
        find_printer_class(class_or_name)
      end.new(@output, options)
    end

    # Find printer class or fail
    #
    # @raise [ArgumentError]
    #
    # @api private
    def find_printer_class(name)
      const_name = name.to_s.capitalize.to_sym
      if const_name.empty? || !TTY::Command::Printers.const_defined?(const_name)
        fail ArgumentError, %(Unknown printer type "#{name}")
      end
      TTY::Command::Printers.const_get(const_name)
    end

    # @api private
    def select_runner(printer, dry_run)
      if dry_run
        DryRunner.new(printer)
      else
        ProcessRunner.new(printer)
      end
    end
  end # Command
end # TTY
