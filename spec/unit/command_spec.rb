# frozen_string_literal: true

RSpec.describe TTY::Command, "::new" do
  it "allows initializing with a params hash" do
    expect { TTY::Command.new({}) }.to_not raise_error
  end
end
