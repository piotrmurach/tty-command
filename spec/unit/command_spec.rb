# encoding: utf-8

RSpec.describe TTY::Command do
  it 'executes command and prints to stdout' do
    output = StringIO.new
    command = TTY::Command.new(output: output)

    out, err = command.execute(:echo, 'hello')

    expect(out).to eq("hello\n")
    expect(err).to eq("")
  end

  it 'executes command and prints to stderr' do
    output = StringIO.new
    command = TTY::Command.new(output: output)

    out, err = command.execute("echo 'hello' 1>& 2")

    expect(out).to eq("")
    expect(err).to eq("hello\n")
  end

  it 'executes command successfully with logging' do
    output = StringIO.new
    uuid = nil
    command = TTY::Command.new(output: output)

    command.execute(:echo, 'hello') do |cmd|
      uuid = cmd.uuid
    end
    output.rewind

    lines = output.readlines
    lines.last.gsub!(/\d+\.\d+/, 'x')
    expect(lines).to eq([
      "[\e[32m#{uuid}\e[0m] Running \e[33;1mecho hello\e[0m\n",
      "[\e[32m#{uuid}\e[0m] \t\e[32mhello\e[0m\n",
      "[\e[32m#{uuid}\e[0m] Finished in x seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n"
    ])
  end

  it "executes command and fails with logging" do
    output = StringIO.new
    uuid = nil
    command = TTY::Command.new(output: output)

    command.execute("echo 'nooo'; exit 1") do |cmd|
      uuid = cmd.uuid
    end
    output.rewind

    lines = output.readlines
    lines.last.gsub!(/\d+\.\d+/, 'x')
    expect(lines).to eq([
      "[\e[32m#{uuid}\e[0m] Running \e[33;1mecho 'nooo'; exit 1\e[0m\n",
      "[\e[32m#{uuid}\e[0m] \t\e[32mnooo\e[0m\n",
      "[\e[32m#{uuid}\e[0m] Finished in x seconds with exit status 1 (\e[31;1mfailed\e[0m)\n"
    ])
  end

  it "raises exception on command failure" do
    output = StringIO.new
    command = TTY::Command.new(output: output)

    expect {
      command.execute!("echo 'nooo'; exit 1")
    }.to raise_error(TTY::Command::FailedError, /Invoking `echo 'nooo'; exit 1` failed with status/)
  end
end
