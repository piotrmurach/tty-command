# encoding: utf-8

RSpec.describe TTY::Command, '#ruby' do
  it "runs ruby with a single string argument" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)
    out, err = cmd.ruby %q{-e "puts 'Hello World'"}
    expect(out).to eq("Hello World\n")
    expect(err).to be_empty
  end

  it "runs ruby with multiple arguments" do
    output = StringIO.new
    cmd = TTY::Command.new(output: output)
    result = double(:success? => true)
    allow(cmd).to receive(:run).with(TTY::Command::RUBY,
      'script.rb', 'foo', 'bar', {}).and_return(result)
    expect(cmd.ruby('script.rb', 'foo', 'bar')).to eq(result)
  end
end
