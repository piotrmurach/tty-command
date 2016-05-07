# encoding: utf-8

RSpec.describe TTY::Command, '#execute' do
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

  it 'executes command successfully with logging without color' do
    output = StringIO.new
    uuid = nil
    command = TTY::Command.new(output: output, color: false)

    command.execute(:echo, 'hello') do |cmd|
      uuid = cmd.uuid
    end
    output.rewind

    lines = output.readlines
    lines.last.gsub!(/\d+\.\d+/, 'x')
    expect(lines).to eq([
      "[#{uuid}] Running echo hello\n",
      "[#{uuid}] \thello\n",
      "[#{uuid}] Finished in x seconds with exit status 0 (successful)\n"
    ])
  end

  it 'executes command successfully with logging without uuid' do
    output = StringIO.new
    command = TTY::Command.new(output: output, uuid: false)

    command.execute(:echo, 'hello')
    output.rewind

    lines = output.readlines
    lines.last.gsub!(/\d+\.\d+/, 'x')
    expect(lines).to eq([
      "Running \e[33;1mecho hello\e[0m\n",
      "\t\e[32mhello\e[0m\n",
      "Finished in x seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n"
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

  it "raises ExitError on command failure" do
    output = StringIO.new
    command = TTY::Command.new(output: output)

    expect {
      command.execute!("echo 'nooo'; exit 1")
    }.to raise_error(TTY::Command::ExitError,
      ["Executing `echo 'nooo'; exit 1` failed with",
       "  exit status: 1",
       "  stdout: nooo",
       "  stderr: Nothing written\n"].join("\n")
    )
  end

  it "redirects STDOUT stream" do
    output = StringIO.new
    command = TTY::Command.new(output: output)

    out, _ = command.execute('echo hello', STDOUT => '/dev/null')

    expect(out).to eq("")
  end
end
