# frozen_string_literal: true

RSpec.describe TTY::Command, '#run' do
  it "times out infinite process without input or output" do
    infinite = fixtures_path('infinite_no_output')
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    expect {
      cmd.run("ruby #{infinite}", timeout: 0.1)
    }.to raise_error(TTY::Command::TimeoutExceeded)
  end

  it "times out an infite process with constant output" do
    infinite = fixtures_path('infinite_output')
    output = StringIO.new
    cmd = TTY::Command.new(output: output, timeout: 0.1)

    expect {
      cmd.run("ruby #{infinite}")
    }.to raise_error(TTY::Command::TimeoutExceeded)
  end

  it "times out an infinite process with constant input data" do
    cli = fixtures_path('infinite_input')
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    range = 1..Float::INFINITY
    infinite_input = range.lazy.map { |x| "hello" }.first(100).join("\n")

    expect {
      cmd.run("ruby #{cli}", input: infinite_input, timeout: 0.1)
    }.to raise_error(TTY::Command::TimeoutExceeded)
  end
end
