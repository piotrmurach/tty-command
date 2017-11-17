# encoding: utf-8

RSpec.describe 'Custom Printer' do
  let(:output) { StringIO.new }

  before do
    stub_const('CustomPrinter', Class.new(TTY::Command::Printers::Abstract) do
      def write(message)
        output << message
      end
    end)
  end

  it "prints command start" do
    printer = CustomPrinter.new(output)
    cmd = TTY::Command::Cmd.new(:echo, "'hello world'")

    printer.print_command_start(cmd)
    output.rewind

    expect(output.string).to eq("echo \\'hello\\ world\\'")
  end

  it "prints command stdout data" do
    printer = CustomPrinter.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello world')

    printer.print_command_out_data(cmd, 'data')
    output.rewind

    expect(output.string).to eq("data")
  end

  it "prints command exit" do
    printer = CustomPrinter.new(output)
    cmd = TTY::Command::Cmd.new(:echo, 'hello world')

    printer.print_command_exit(cmd)
    output.rewind

    expect(output.string).to be_empty
  end

  it "accepts options" do
    printer = CustomPrinter.new(output, foo: :bar)
    expect(printer.options[:foo]).to eq(:bar)
  end
end
