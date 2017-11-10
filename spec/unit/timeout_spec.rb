# encoding: utf-8

RSpec.describe TTY::Command, '#run' do
  it "times out after a specified period" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)
    expect {
      cmd.run("while test 1; do echo 'hello'; sleep 0.1; done", timeout: 0.1)
    }.to raise_error(TTY::Command::TimeoutExceeded)
  end

  it "times out globally all commands" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output, timeout: 0.1)
    expect {
      cmd.run("while test 1; do echo 'hello'; sleep 0.1; done")
    }.to raise_error(TTY::Command::TimeoutExceeded)
  end

  it "reads user input data until timeout" do
    cli = tmp_path('cli')
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    expect {
     cmd.run(cli, input: "Piotr\n", timeout: 0.01)
    }.to raise_error(TTY::Command::TimeoutExceeded)
  end
end
