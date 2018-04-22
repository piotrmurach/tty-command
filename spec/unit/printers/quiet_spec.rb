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

  it "doesn't print output on success when only_output_on_error is true" do
    zero_exit = fixtures_path('zero_exit')
    printer = TTY::Command::Printers::Quiet
    cmd = TTY::Command.new(output: output, printer: printer)

    cmd.run!(:ruby, zero_exit, only_output_on_error: true)
    cmd.run!(:ruby, zero_exit)

    output.rewind

    lines = output.readlines.map(&:chomp)

    expect(lines).to eq([
      "yess"
    ])
  end

  it "prints output on error when only_output_on_error is true" do
    non_zero_exit = fixtures_path('non_zero_exit')
    printer = TTY::Command::Printers::Quiet
    cmd = TTY::Command.new(output: output, printer: printer)

    cmd.run!(:ruby, non_zero_exit, only_output_on_error: true)
    cmd.run!(:ruby, non_zero_exit)

    output.rewind

    lines = output.readlines.map(&:chomp)

    expect(lines).to eq([
      "nooo",
      "nooo"
    ])
  end
end
