# encoding: utf-8

RSpec.describe TTY::Command, '#execute' do
  let(:output) { StringIO.new }

  it "executes command in dry run mode" do
    command = TTY::Command.new(output: output, dry_run: true)
    uuid = nil
    command.execute(:echo, 'hello', 'world') do |cmd|
      uuid = cmd.uuid
    end
    output.rewind

    expect(output.read).to eq(
      "[\e[32m#{uuid}\e[0m] \e[34m(dry run)\e[0m \e[33;1mecho hello world\e[0m\n")
  end

  it "allows to execute command in dry mode" do
    command = TTY::Command.new(output: output)
    uuid = nil
    command.execute(:echo, 'hello', 'world', dry_run: true) do |cmd|
      uuid = cmd.uuid
    end
    output.rewind

    expect(output.read).to eq(
      "[\e[32m#{uuid}\e[0m] \e[34m(dry run)\e[0m \e[33;1mecho hello world\e[0m\n")
  end

  it "doesn't collect printout to stdin or stderr" do
    cmd = TTY::Command.new(output: output, dry_run: true)
    out, err = cmd.execute(:echo, 'hello', 'world')

    expect(out).to be_empty
    expect(err).to be_empty
  end
end
