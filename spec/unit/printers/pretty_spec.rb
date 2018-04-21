# encoding: utf-8

RSpec.describe TTY::Command::Printers::Pretty do
  let(:output) { StringIO.new }
  let(:uuid) { 'aaaaaa-xxx' }

  it "prints command start in color" do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_start(cmd)
    output.rewind

    expect(output.string).
      to eq("[\e[32maaaaaa\e[0m] Running \e[33;1mecho hello\e[0m\n")
  end

  it "prints command start without color" do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    printer = TTY::Command::Printers::Pretty.new(output, color: false)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_start(cmd)
    output.rewind

    expect(output.string).to eq("[aaaaaa] Running echo hello\n")
  end

  it "prints command start without uuid" do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    printer = TTY::Command::Printers::Pretty.new(output, uuid: false)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_start(cmd)
    output.rewind

    expect(output.string).to eq("Running \e[33;1mecho hello\e[0m\n")
  end

  it "prints command stdout data" do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_out_data(cmd, 'hello', 'world')
    output.rewind

    expect(output.string).to eq("[\e[32maaaaaa\e[0m] \thello world\n")
  end

  it "prints command stderr data" do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_err_data(cmd, 'hello', 'world')
    output.rewind

    expect(output.string).
      to eq("[\e[32maaaaaa\e[0m] \t\e[31mhello world\e[0m\n")
  end

  it "prints successful command exit in color" do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_exit(cmd, 0, 5.321)
    output.rewind

    expect(output.string).to eq("[\e[32maaaaaa\e[0m] Finished in 5.321 seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n")
  end

  it "prints failure command exit in color" do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_exit(cmd, 1, 5.321)
    output.rewind

    expect(output.string).to eq("[\e[32maaaaaa\e[0m] Finished in 5.321 seconds with exit status 1 (\e[31;1mfailed\e[0m)\n")
  end

  it "prints command exit without exit status in color" do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    printer = TTY::Command::Printers::Pretty.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello')

    printer.print_command_exit(cmd, nil, 5.321)
    output.rewind

    expect(output.string).to eq("[\e[32maaaaaa\e[0m] Finished in 5.321 seconds (\e[31;1mfailed\e[0m)\n")
  end

  it "doesn't print output on success when only_output_on_error is true" do
    zero_exit = fixtures_path('zero_exit')
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    printer = TTY::Command::Printers::Pretty
    cmd = TTY::Command.new(output: output, printer: printer)

    cmd.run!(:ruby, zero_exit, only_output_on_error: true)
    cmd.run!(:ruby, zero_exit)

    output.rewind

    lines = output.readlines
    lines.each { |line| line.gsub!(/\d+\.\d+(?= seconds)/, 'x') }

    expect(lines).to eq([
      "[\e[32maaaaaa\e[0m] Running \e[33;1mruby #{zero_exit}\e[0m\n",
      "[\e[32maaaaaa\e[0m] Finished in x seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n",
      "[\e[32maaaaaa\e[0m] Running \e[33;1mruby #{zero_exit}\e[0m\n",
      "[\e[32maaaaaa\e[0m] \tyess\n",
      "[\e[32maaaaaa\e[0m] Finished in x seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n"
    ])
  end

  it "prints output on error & raises ExitError when only_output_on_error is true" do
    non_zero_exit = fixtures_path('non_zero_exit')
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    printer = TTY::Command::Printers::Pretty
    cmd = TTY::Command.new(output: output, printer: printer)

    cmd.run!(:ruby, non_zero_exit, only_output_on_error: true)
    cmd.run!(:ruby, non_zero_exit)

    output.rewind

    lines = output.readlines
    lines.each { |line| line.gsub!(/\d+\.\d+(?= seconds)/, 'x') }

    expect(lines).to eq([
      "[\e[32maaaaaa\e[0m] Running \e[33;1mruby #{non_zero_exit}\e[0m\n",
      "[\e[32maaaaaa\e[0m] \tnooo\n",
      "[\e[32maaaaaa\e[0m] Finished in x seconds with exit status 1 (\e[31;1mfailed\e[0m)\n",
      "[\e[32maaaaaa\e[0m] Running \e[33;1mruby #{non_zero_exit}\e[0m\n",
      "[\e[32maaaaaa\e[0m] \tnooo\n",
      "[\e[32maaaaaa\e[0m] Finished in x seconds with exit status 1 (\e[31;1mfailed\e[0m)\n"
    ])
  end

  it "prints output on error when only_output_on_error is true" do
    non_zero_exit = fixtures_path('non_zero_exit')
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    printer = TTY::Command::Printers::Pretty
    cmd = TTY::Command.new(output: output, printer: printer)

    expect {
      cmd.run(:ruby, non_zero_exit, only_output_on_error: true)
    }.to raise_error(TTY::Command::ExitError)

    expect {
      cmd.run(:ruby, non_zero_exit)
    }.to raise_error(TTY::Command::ExitError)

    output.rewind

    lines = output.readlines
    lines.each { |line| line.gsub!(/\d+\.\d+(?= seconds)/, 'x') }

    expect(lines).to eq([
      "[\e[32maaaaaa\e[0m] Running \e[33;1mruby #{non_zero_exit}\e[0m\n",
      "[\e[32maaaaaa\e[0m] \tnooo\n",
      "[\e[32maaaaaa\e[0m] Finished in x seconds with exit status 1 (\e[31;1mfailed\e[0m)\n",
      "[\e[32maaaaaa\e[0m] Running \e[33;1mruby #{non_zero_exit}\e[0m\n",
      "[\e[32maaaaaa\e[0m] \tnooo\n",
      "[\e[32maaaaaa\e[0m] Finished in x seconds with exit status 1 (\e[31;1mfailed\e[0m)\n"
    ])
  end
end
