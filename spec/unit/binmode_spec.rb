RSpec.describe TTY::Command, '#run' do
  it "encodes output as unicode by default" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)
    out, _ = cmd.run("echo 'hello'")

    expect(out.encoding).to eq(Encoding::UTF_8)
  end

  it "encodes output as binary" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)
    out, _ = cmd.run("echo 'hello'", binmode: true)

    expect(out.encoding).to eq(Encoding::BINARY)
  end

  it "encodes all commands output as binary" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output, binmode: true)
    out, _ = cmd.run("echo 'hello'")

    expect(out.encoding).to eq(Encoding::BINARY)
  end
end
