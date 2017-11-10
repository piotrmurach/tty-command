# encoding: utf-8
# frozen_string_literal: true

RSpec.describe TTY::Command, 'redirect' do
  it "accepts standard shell redirects" do
    output = StringIO.new
    command = TTY::Command.new(output: output)

    out, err = command.run("echo 'hello' 1>& 2")

    expect(out).to eq("")
    expect(err).to eq("hello\n")
  end

  it "redirects :out -> :err" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, err = cmd.run("echo hello", :out => :err)

    expect(out).to be_empty
    expect(err).to eq("hello\n")
  end

  it "redirects :stdout -> :stderr" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, err = cmd.run("echo hello", :stdout => :stderr)

    expect(out).to be_empty
    expect(err).to eq("hello\n")
  end

  it "redirects 1 -> 2" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, err = cmd.run("echo hello", 1 => 2)

    expect(out).to be_empty
    expect(err).to eq("hello\n")
  end


  it "redirects STDOUT -> :err" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, err = cmd.run("echo hello", STDOUT => :err)

    expect(out).to be_empty
    expect(err).to eq("hello\n")
  end

  it "redirects STDOUT -> '/dev/null" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, _ = cmd.run('echo hello', :out => IO::NULL)

    expect(out).to eq("")
  end

  it "redirects to a file" do
    file = tmp_path('log')
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, err = cmd.run('echo hello', :out => file)

    expect(out).to be_empty
    expect(err).to be_empty
    expect(File.read(file)).to eq("hello\n")
  end

  it "redirects to a file as an array value" do
    file = tmp_path('log')
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, err = cmd.run('echo hello', :out => [file, 'w', 0600])

    expect(out).to be_empty
    expect(err).to be_empty
    expect(File.read(file)).to eq("hello\n")
    expect(File.stat(file).mode.to_s(8)[2..5]).to eq('0600')
  end

  it "redirects multiple fds to a file" do
    file = tmp_path('log')
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, err = cmd.run('echo hello', [:out, :err] => file)

    expect(out).to be_empty
    expect(err).to be_empty
    expect(File.read(file)).to eq("hello\n")
  end
end
