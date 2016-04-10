# encoding: utf-8

RSpec.describe TTY::Command::Printer do
  let(:output) { StringIO.new }
  let(:uuid) { 'aaaaaa' }

  it "prints command start in color" do
    printer = TTY::Command::Printer.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    allow(cmd).to receive(:uuid).and_return(uuid)
    printer.print_command_start(cmd)
    output.rewind

    expect(output.string).
      to eq("[\e[32maaaaaa\e[0m] Running \e[33;1mecho hello\e[0m\n")
  end

  it "prints command stdout data" do
    printer = TTY::Command::Printer.new(output)

    printer.print_command_out_data(uuid, 'hello', 'world')
    output.rewind

    expect(output.string).
      to eq("[\e[32maaaaaa\e[0m] \t\e[32mhello world\e[0m\n")
  end

  it "prints command stderr data" do
    printer = TTY::Command::Printer.new(output)

    printer.print_command_err_data(uuid, 'hello', 'world')
    output.rewind

    expect(output.string).
      to eq("[\e[32maaaaaa\e[0m] \t\e[31mhello world\e[0m\n")
  end

  it "prints successful command exit in color" do
    printer = TTY::Command::Printer.new(output)

    printer.print_command_exit(uuid, 0, 5.321)
    output.rewind

    expect(output.string).to eq("[\e[32maaaaaa\e[0m] Finished in 5.321 seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n")
  end

  it "prints failure command exit in color" do
    printer = TTY::Command::Printer.new(output)

    printer.print_command_exit(uuid, 1, 5.321)
    output.rewind

    expect(output.string).to eq("[\e[32maaaaaa\e[0m] Finished in 5.321 seconds with exit status 1 (\e[31;1mfailed\e[0m)\n")
  end

  it "prints command exit without exit status in color" do
    printer = TTY::Command::Printer.new(output)

    printer.print_command_exit(uuid, nil, 5.321)
    output.rewind

    expect(output.string).to eq("[\e[32maaaaaa\e[0m] Finished in 5.321 seconds (\e[31;1mfailed\e[0m)\n")
  end
end
