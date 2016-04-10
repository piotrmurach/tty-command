# encoding: utf-8

RSpec.describe TTY::Command::Result do
  it "exits successfully" do
    result = TTY::Command::Result.new(0, '', '')
    expect(result.exited?).to eq(true)
    expect(result.success?).to eq(true)
  end

  it "exist with non-zero code" do
    result = TTY::Command::Result.new(127, '', '')
    expect(result.exited?).to eq(true)
    expect(result.success?).to eq(false)
  end

  it "doesn't exit" do
    result = TTY::Command::Result.new(nil, '', '')
    expect(result.exited?).to eq(false)
    expect(result.success?).to eq(false)
  end

  it "reads stdout" do
    result = TTY::Command::Result.new(0, 'foo', '')
    expect(result.out).to eq('foo')
  end

  it "isn't equivalent with another object" do
    result = TTY::Command::Result.new(0, '', '')
    expect(result).to_not eq(:other)
  end

  it "is the same with equivalent object" do
    result_foo = TTY::Command::Result.new(0, 'foo', 'bar')
    result_bar = TTY::Command::Result.new(0, 'foo', 'bar')
    expect(result_foo).to eq(result_bar)
  end
end
