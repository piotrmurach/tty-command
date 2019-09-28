# frozen_string_literal: true

RSpec.describe TTY::Command, '#test' do
  it "implements classic bash command" do
    cmd = TTY::Command.new
    result = double(:success? => true)
    allow(cmd).to receive(:run!).with(:test, '-e /etc/passwd').and_return(result)
    expect(cmd.test("-e /etc/passwd")).to eq(true)
    expect(cmd).to have_received(:run!)
  end
end
