# frozen_string_literal: true

RSpec.describe TTY::Command, ':pty' do
  it "executes command in pseudo terminal mode as global option",
     unless: RSpec::Support::OS.windows? do

    color_cli = fixtures_path('color')
    output = StringIO.new
    cmd = TTY::Command.new(output: output, pty: true)

    out, err = cmd.run(color_cli)

    expect(err).to eq('')
    expect(out).to eq("\e[32mcolored\e[0m\n")
  end

  it "executes command in pseudo terminal mode as command option",
      unless: RSpec::Support::OS.windows? do

    color_cli = fixtures_path('color')
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, err = cmd.run(color_cli, pty: true)

    expect(err).to eq('')
    expect(out).to eq("\e[32mcolored\e[0m\n")
  end

  it "logs phased output in pseudo terminal mode",
      unless: RSpec::Support::OS.windows? do

    phased_output = fixtures_path('phased_output')
    uuid= 'xxxx'
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    output = StringIO.new
    cmd = TTY::Command.new(output: output)

    out, err = cmd.run("ruby #{phased_output}", pty: true)

    expect(out).to eq('.' * 10)
    expect(err).to eq('')

    output.rewind
    lines = output.readlines
    lines.last.gsub!(/\d+\.\d+/, 'x')
    expect(lines).to eq([
      "[\e[32m#{uuid}\e[0m] Running \e[33;1mruby #{phased_output}\e[0m\n",
      "[\e[32m#{uuid}\e[0m] \t.\n",
      "[\e[32m#{uuid}\e[0m] \t.\n",
      "[\e[32m#{uuid}\e[0m] \t.\n",
      "[\e[32m#{uuid}\e[0m] \t.\n",
      "[\e[32m#{uuid}\e[0m] \t.\n",
      "[\e[32m#{uuid}\e[0m] \t.\n",
      "[\e[32m#{uuid}\e[0m] \t.\n",
      "[\e[32m#{uuid}\e[0m] \t.\n",
      "[\e[32m#{uuid}\e[0m] \t.\n",
      "[\e[32m#{uuid}\e[0m] \t.\n",
      "[\e[32m#{uuid}\e[0m] Finished in x seconds with exit status 0 (\e[32;1msuccessful\e[0m)\n"
    ])
  end
end
