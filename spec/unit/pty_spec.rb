RSpec.describe TTY::Command, ':pty' do
  it "executes command in pseudo terminal mode as global option", unless: RSpec::Support::OS.windows? do
    color_cli = tmp_path('color')
    output = StringIO.new
    cmd = TTY::Command.new(output: output, pty: true)

    out, err = cmd.run(color_cli)

    expect(err).to eq('')
    expect(out).to eq("\e[32mcolored\e[0m\n")
  end

  it "executes command in pseudo terminal mode as command option", unless: RSpec::Support::OS.windows? do
    color_cli = tmp_path('color')
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, err = cmd.run(color_cli, pty: true)

    expect(err).to eq('')
    expect(out).to eq("\e[32mcolored\e[0m\n")
  end
end
