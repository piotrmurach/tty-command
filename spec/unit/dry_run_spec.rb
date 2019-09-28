# frozen_string_literal: true

RSpec.describe TTY::Command, 'dry run' do
  let(:output) { StringIO.new }

  it "queries for dry mode" do
    command = TTY::Command.new(dry_run: false)
    expect(command.dry_run?).to eq(false)
  end

  it "runs command in dry run mode" do
    uuid= 'xxxx'
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    command = TTY::Command.new(output: output, dry_run: true)

    command.run(:echo, 'hello', 'world')

    output.rewind
    expect(output.read).to eq(
      "[\e[32m#{uuid}\e[0m] \e[34m(dry run)\e[0m \e[33;1mecho hello world\e[0m\n")
  end

  it "allows to run command in dry mode" do
    uuid= 'xxxx'
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    command = TTY::Command.new(output: output)

    command.run(:echo, 'hello', 'world', dry_run: true)

    output.rewind
    expect(output.read).to eq(
      "[\e[32m#{uuid}\e[0m] \e[34m(dry run)\e[0m \e[33;1mecho hello world\e[0m\n")
  end

  it "doesn't collect printout to stdin or stderr" do
    cmd = TTY::Command.new(output: output, dry_run: true)
    out, err = cmd.run(:echo, 'hello', 'world')

    expect(out).to be_empty
    expect(err).to be_empty
  end
end
