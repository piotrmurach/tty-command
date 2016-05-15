# encoding: utf-8

RSpec.describe TTY::Command::Printers::Progress do
  let(:output) { StringIO.new }

  it "doesn't print command start" do
    printer = TTY::Command::Printers::Progress.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_start(cmd)
    output.rewind

    expect(output.string).to be_empty
  end

  it "doesn't print command stdout data" do
    printer = TTY::Command::Printers::Progress.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_out_data(cmd, 'hello', 'world')
    output.rewind

    expect(output.string).to be_empty
  end

  it "prints successful command exit in color" do
    printer = TTY::Command::Printers::Progress.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_exit(cmd, 0, 5.321)
    output.rewind

    expect(output.string).to eq("\e[32m.\e[0m")
  end

  it "prints failure command exit in color" do
    printer = TTY::Command::Printers::Progress.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_exit(cmd, 1, 5.321)
    output.rewind

    expect(output.string).to eq("\e[31mF\e[0m")
  end
end
