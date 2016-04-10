require 'spec_helper'

describe Tty::Command do
  it 'has a version number' do
    expect(Tty::Command::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
