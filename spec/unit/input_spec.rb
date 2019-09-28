# frozen_string_literal: true

RSpec.describe TTY::Command, 'input' do
  it "reads user input data" do
    cli = fixtures_path('cli')
    output = StringIO.new
    command = TTY::Command.new(output: output)

    out, _ = command.run("ruby #{cli}", input: "Piotr\n")

    expect(out.chomp).to eq("Your name: Piotr")
  end
end
