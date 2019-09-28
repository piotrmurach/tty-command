# frozen_string_literal: true

RSpec.describe TTY::Command::ExitError, 'info' do
  it "displays stdin & stdout" do
    result = double(exit_status: 157, out: 'out content', err: 'err content')
    error = described_class.new(:cat, result)
    expect(error.message).to eq([
      "Running `cat` failed with\n",
      "  exit status: 157\n",
      "  stdout: out content\n",
      "  stderr: err content\n"
    ].join)
  end

  it "explains no stdin & stdout" do
    result = double(exit_status: 157, out: '', err: '')
    error = described_class.new(:cat, result)
    expect(error.message).to eq([
      "Running `cat` failed with\n",
      "  exit status: 157\n",
      "  stdout: Nothing written\n",
      "  stderr: Nothing written\n"
    ].join)
  end
end
