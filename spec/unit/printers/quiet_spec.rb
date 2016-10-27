# encoding: utf-8

RSpec.describe TTY::Command::Printers::Quiet do
  let(:output) { StringIO.new }

  it "doesn't print command start or exit" do
    printer = TTY::Command::Printers::Quiet.new(output)
    cmd = TTY::Command::Cmd.new("echo hello")

    printer.print_command_start(cmd)
    printer.print_command_exit(cmd, 0)
    output.rewind

    expect(output.string).to be_empty
  end

  it "prints command stdout data" do
    printer = TTY::Command::Printers::Quiet.new(output)
    cmd = TTY::Command::Cmd.new("echo hello")

    printer.print_command_out_data(cmd, 'hello', 'world')
    output.rewind

    expect(output.string).to eq("hello world")
  end

  it "prints command stderr data" do
    printer = TTY::Command::Printers::Quiet.new(output)
    cmd = TTY::Command::Cmd.new("echo hello")

    printer.print_command_err_data(cmd, 'hello', 'world')
    output.rewind

    expect(output.string).to eq("hello world")
  end
end
