# frozen_string_literal: true

RSpec.describe TTY::Command, '#run' do
  it "encodes output as unicode by default" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)
    out, _ = cmd.run("echo '昨夜のコンサートは'")

    expect(out.encoding).to eq(Encoding::UTF_8)
    # expect(out.chomp).to eq("昨夜のコンサートは")
  end

  it "encodes output as binary" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)
    out, _ = cmd.run("echo '昨夜のコンサートは'", binmode: true)

    expect(out.encoding).to eq(Encoding::BINARY)
    #expect(out.chomp).to eq("\xE6\x98\xA8\xE5\xA4\x9C\xE3\x81\xAE\xE3\x82\xB3\xE3\x83\xB3\xE3\x82\xB5\xE3\x83\xBC\xE3\x83\x88\xE3\x81\xAF".force_encoding(Encoding::BINARY))
  end

  it "encodes all commands output as binary" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output, binmode: true)
    out, _ = cmd.run("echo 'hello'")

    expect(out.encoding).to eq(Encoding::BINARY)
  end
end
