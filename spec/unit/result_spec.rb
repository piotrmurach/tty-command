# frozen_string_literal: true

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

  it "accesses exit code" do
    result = TTY::Command::Result.new(127, '', '')
    expect(result.to_i).to eq(127)
    expect(result.to_s).to eq('127')
  end

  it "provides runtime" do
    result = TTY::Command::Result.new(0, '', '', 5.4)
    expect(result.runtime).to eq(5.4)
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

  it "iterates over output with default delimiter" do
    result = TTY::Command::Result.new(0, "line1\nline2\nline3", '')
    expect(result.to_a).to eq(['line1', 'line2', 'line3'])
  end

  it "iterates over output with global delimiter" do
    allow(TTY::Command).to receive(:record_separator).and_return("\t")
    result = TTY::Command::Result.new(0, "line1\tline2\tline3", '')
    expect(result.each.to_a).to eq(['line1', 'line2', 'line3'])
  end

  it "iterates over output with argument delimiter" do
    result = TTY::Command::Result.new(0, "line1\tline2\tline3", '')
    expect(result.each("\t").to_a).to eq(['line1', 'line2', 'line3'])
  end
end
