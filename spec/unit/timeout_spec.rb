# encoding: utf-8

RSpec.describe TTY::Command, '#run' do
  it "times out after a specified period" do
    infinite = fixtures_path('infinite')
    output = StringIO.new
    cmd = TTY::Command.new(output: output)
    expect {
      cmd.run("ruby #{infinite}", timeout: 0.1)
    }.to raise_error(TTY::Command::TimeoutExceeded)
  end

  it "times out globally all commands" do
    infinite = fixtures_path('infinite')
    output = StringIO.new
    cmd = TTY::Command.new(output: output, timeout: 0.1)
    expect {
      cmd.run("ruby #{infinite}")
    }.to raise_error(TTY::Command::TimeoutExceeded)
  end

  it "reads user input data until timeout" do
    cli = fixtures_path('cli')
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    expect {
     cmd.run("ruby #{cli}", input: "Piotr\n", timeout: 0.01)
    }.to raise_error(TTY::Command::TimeoutExceeded)
  end
end
