# encoding: utf-8

RSpec.describe TTY::Command do
  it "fails to find printer based on name" do
    expect {
      TTY::Command.new(printer: :unknown)
    }.to raise_error(ArgumentError, /Unknown printer type "unknown"/)
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
end
