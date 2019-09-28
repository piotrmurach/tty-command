# frozen_string_literal: true

RSpec.describe TTY::Command, ':printer' do
  it "fails to find printer for nil" do
    expect {
      TTY::Command.new(printer: nil)
    }.to raise_error(ArgumentError, /Unknown printer type ""/)
  end

  it "fails to find printer based on name" do
    expect {
      TTY::Command.new(printer: :unknown)
    }.to raise_error(ArgumentError, /Unknown printer type "unknown"/)
  end

  it "detects null printer" do
    cmd = TTY::Command.new(printer: :null)
    expect(cmd.printer).to be_an_instance_of(TTY::Command::Printers::Null)
  end

  it "detects printer based on name" do
    cmd = TTY::Command.new(printer: :progress)
    expect(cmd.printer).to be_an_instance_of(TTY::Command::Printers::Progress)
  end

  it "uses printer based on class name" do
    output = StringIO.new
    printer = TTY::Command::Printers::Pretty
    cmd = TTY::Command.new(output: output, printer: printer)
    expect(cmd.printer).to be_an_instance_of(TTY::Command::Printers::Pretty)
  end

  it "uses printer based on instance" do
    output = StringIO.new
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command.new(printer: printer)
    expect(cmd.printer).to be_an_instance_of(TTY::Command::Printers::Pretty)
  end

  it "uses custom printer" do
    stub_const('CustomPrinter', Class.new(TTY::Command::Printers::Abstract) do
      def write(message)
        output << message
      end
    end)
    printer = CustomPrinter
    cmd = TTY::Command.new(printer: printer)
    expect(cmd.printer).to be_an_instance_of(CustomPrinter)
  end
end
