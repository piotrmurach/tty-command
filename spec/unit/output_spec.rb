# frozen_string_literal: true

RSpec.describe TTY::Command, ":output", type: :sandbox do
  it "runs command and prints to a file" do
    stub_const("Tee", Class.new do
      def initialize(file)
        @file = file
      end

      def <<(message)
        @file << message
        @file.close
      end
    end)

    file = "foo.log"
    output = Tee.new(File.open(file, "w"))

    command = TTY::Command.new(output: output, printer: :quiet)
    command.run("echo hello")

    expect(File.read(file).chomp).to eq("hello")
  end
end
