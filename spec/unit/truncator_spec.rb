# frozen_string_literal: true

RSpec.describe TTY::Command::Truncator do
  it "writes nil content" do
    truncator = described_class.new(max_size: 2)

    truncator.write(nil)

    expect(truncator.read).to eq('')
  end

  it "writes content within maximum size" do
    truncator = described_class.new(max_size: 2)

    truncator.write("a")

    expect(truncator.read).to eq("a")
  end

  it "writes both prefix and suffix" do
    truncator = described_class.new(max_size: 2)

    truncator.write("abc")
    truncator.write("d")

    expect(truncator.read).to eq("abcd")
  end

  it "writes more bytes letter" do
    truncator = described_class.new(max_size: 1000)
    multibytes_string = "’test’"

    truncator.write(multibytes_string)

    expect(truncator.read).to eq(multibytes_string)
  end

  it "overflows prefix and suffix " do
    truncator = described_class.new(max_size: 2)

    truncator.write("abc")
    truncator.write("d")
    truncator.write("e")

    expect(truncator.read).to eq("ab\n... omitting 1 bytes ...\nde")
  end

  it "omits bytes " do
    truncator = described_class.new(max_size: 2)

    truncator.write("abc___________________yz")

    expect(truncator.read).to eq("ab\n... omitting 20 bytes ...\nyz")
  end

  it "reflows suffix with less content" do
    truncator = described_class.new(max_size: 2)

    truncator.write("abc____________________y")
    truncator.write("z")

    expect(truncator.read).to eq("ab\n... omitting 21 bytes ...\nyz")
  end

  it "reflows suffix with more content" do
    truncator = described_class.new(max_size: 2)

    truncator.write("abc____________________y")
    truncator.write("zwx")

    expect(truncator.read).to eq("ab\n... omitting 23 bytes ...\nwx")
  end
end
