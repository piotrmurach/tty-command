# encoding: utf-8

RSpec.describe TTY::Command::Printers::Pretty do
  let(:output) { StringIO.new }
  let(:uuid) { 'aaaaaa' }

  it "prints command start in color" do
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    allow(cmd).to receive(:uuid).and_return(uuid)
    printer.print_command_start(cmd)
    output.rewind

    expect(output.string).
      to eq("[\e[32maaaaaa\e[0m] Running \e[33;1mecho hello\e[0m\n")
  end

  it "prints command start without color" do
    printer = TTY::Command::Printers::Pretty.new(output, color: false)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')
    allow(cmd).to receive(:uuid).and_return(uuid)

    printer.print_command_start(cmd)
    output.rewind

    expect(output.string).to eq("[aaaaaa] Running echo hello\n")
  end

  it "prints command start without uuid" do
    printer = TTY::Command::Printers::Pretty.new(output, uuid: false)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')
    allow(cmd).to receive(:uuid).and_return(uuid)

    printer.print_command_start(cmd)
    output.rewind

    expect(output.string).to eq("Running \e[33;1mecho hello\e[0m\n")
  end

  it "prints command stdout data" do
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')
    allow(cmd).to receive(:uuid).and_return(uuid)

    printer.print_command_out_data(cmd, 'hello', 'world')
    output.rewind

    expect(output.string).
      to eq("[\e[32maaaaaa\e[0m] \t\e[32mhello world\e[0m\n")
  end

  it "prints command stderr data" do
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')
    allow(cmd).to receive(:uuid).and_return(uuid)

    printer.print_command_err_data(cmd, 'hello', 'world')
    output.rewind

    expect(output.string).
      to eq("[\e[32maaaaaa\e[0m] \t\e[31mhello world\e[0m\n")
  end

  it "prints successful command exit in color" do
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')
    allow(cmd).to receive(:uuid).and_return(uuid)

    printer.print_command_exit(cmd, 0, 5.321)
    output.rewind

    expect(output.string).to eq("[\e[32maaaaaa\e[0m] Finished in 5.321 seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n")
  end

  it "prints failure command exit in color" do
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')
    allow(cmd).to receive(:uuid).and_return(uuid)

    printer.print_command_exit(cmd, 1, 5.321)
    output.rewind

    expect(output.string).to eq("[\e[32maaaaaa\e[0m] Finished in 5.321 seconds with exit status 1 (\e[31;1mfailed\e[0m)\n")
  end

  it "prints command exit without exit status in color" do
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')
    allow(cmd).to receive(:uuid).and_return(uuid)

    printer.print_command_exit(cmd, nil, 5.321)
    output.rewind

    expect(output.string).to eq("[\e[32maaaaaa\e[0m] Finished in 5.321 seconds (\e[31;1mfailed\e[0m)\n")
  end
end
