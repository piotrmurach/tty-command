RSpec.describe TTY::Command, '#run' do
  it 'runs command and prints to stdout' do
    output = StringIO.new
    command = TTY::Command.new(output: output)

    out, err = command.run(:echo, 'hello')

    expect(out.chomp).to eq("hello")
    expect(err).to eq("")
  end

  it 'runs command successfully with logging' do
    output = StringIO.new
    uuid= 'xxxx'
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    command = TTY::Command.new(output: output)

    command.run(:echo, 'hello')

    output.rewind
    lines = output.readlines
    lines.last.gsub!(/\d+\.\d+/, 'x')
    expect(lines).to eq([
      "[\e[32m#{uuid}\e[0m] Running \e[33;1mecho hello\e[0m\n",
      "[\e[32m#{uuid}\e[0m] \thello\n",
      "[\e[32m#{uuid}\e[0m] Finished in x seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n"
    ])
  end

  it 'runs command successfully with logging without color' do
    output = StringIO.new
    uuid= 'xxxx'
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    command = TTY::Command.new(output: output, color: false)

    command.run(:echo, 'hello')

    output.rewind
    lines = output.readlines
    lines.last.gsub!(/\d+\.\d+/, 'x')
    expect(lines).to eq([
      "[#{uuid}] Running echo hello\n",
      "[#{uuid}] \thello\n",
      "[#{uuid}] Finished in x seconds with exit status 0 (successful)\n"
    ])
  end

  it 'runs command successfully with logging without uuid set globally' do
    output = StringIO.new
    command = TTY::Command.new(output: output, uuid: false)

    command.run(:echo, 'hello')
    output.rewind

    lines = output.readlines
    lines.last.gsub!(/\d+\.\d+/, 'x')
    expect(lines).to eq([
      "Running \e[33;1mecho hello\e[0m\n",
      "\thello\n",
      "Finished in x seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n"
    ])
  end

  it 'runs command successfully with logging without uuid set locally' do
    output = StringIO.new
    command = TTY::Command.new(output: output)

    command.run(:echo, 'hello', uuid: false)
    output.rewind

    lines = output.readlines
    lines.last.gsub!(/\d+\.\d+/, 'x')
    expect(lines).to eq([
      "Running \e[33;1mecho hello\e[0m\n",
      "\thello\n",
      "Finished in x seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n"
    ])
  end

  it "runs command and fails with logging" do
    non_zero_exit = fixtures_path('non_zero_exit')
    output = StringIO.new
    uuid= 'xxxx'
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    command = TTY::Command.new(output: output)

    command.run!("ruby #{non_zero_exit}")

    output.rewind
    lines = output.readlines
    lines.last.gsub!(/\d+\.\d+/, 'x')
    expect(lines).to eq([
      "[\e[32m#{uuid}\e[0m] Running \e[33;1mruby #{non_zero_exit}\e[0m\n",
      "[\e[32m#{uuid}\e[0m] \tnooo\n",
      "[\e[32m#{uuid}\e[0m] Finished in x seconds with exit status 1 (\e[31;1mfailed\e[0m)\n"
    ])
  end

  it "raises ExitError on command failure" do
    non_zero_exit = fixtures_path('non_zero_exit')
    output = StringIO.new
    command = TTY::Command.new(output: output)

    expect {
      command.run("ruby #{non_zero_exit}")
    }.to raise_error(TTY::Command::ExitError,
      ["Running `ruby #{non_zero_exit}` failed with",
       "  exit status: 1",
       "  stdout: nooo",
       "  stderr: Nothing written\n"].join("\n")
    )
  end

  it "streams output data" do
    stream = fixtures_path('stream')
    out_stream = StringIO.new
    command = TTY::Command.new(output: out_stream)
    output = ''
    error = ''
    command.run("ruby #{stream}") do |out, err|
     output << out if out
     error << err if err
    end
    expect(output.gsub(/\r\n|\n/,'')).to eq("hello 1hello 2hello 3")
    expect(error).to eq('')
  end

  it "preserves ANSI codes" do
    output = StringIO.new
    command = TTY::Command.new(output: output, printer: :quiet)

    out, _ = command.run("echo \e[35mhello\e[0m")

    expect(out.chomp).to eq("\e[35mhello\e[0m")
    expect(output.string.chomp).to eq("\e[35mhello\e[0m")
  end

  it "logs phased output in one line" do
    phased_output = fixtures_path('phased_output')
    uuid= 'xxxx'
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, err = cmd.run("ruby #{phased_output}")

    expect(out).to eq('.' * 10)
    expect(err).to eq('')

    output.rewind
    lines = output.readlines
    lines.last.gsub!(/\d+\.\d+/, 'x')
    expect(lines).to eq([
      "[\e[32m#{uuid}\e[0m] Running \e[33;1mruby #{phased_output}\e[0m\n",
      "[\e[32m#{uuid}\e[0m] \t..........\n",
      "[\e[32m#{uuid}\e[0m] Finished in x seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n"
    ])
  end
end
