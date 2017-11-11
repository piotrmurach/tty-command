# encoding: utf-8

require 'fileutils'

RSpec.describe TTY::Command, ':output' do
  it 'runs command and prints to a file' do
    stub_const('Tee', Class.new do
      def initialize(file)
        @file = file
      end
      def <<(message)
        @file << message
        @file.close
      end
    end)

    unless File.exist?(tmp_path)
      FileUtils.mkdir(tmp_path)
    end
    file = tmp_path('foo.log')
    output = Tee.new(File.open(file, 'w'))

    command = TTY::Command.new(output: output, printer: :quiet)
    command = command.run("echo hello")

    expect(File.read(file)).to eq("hello\n")

    FileUtils.rm_rf(file)
  end
end
