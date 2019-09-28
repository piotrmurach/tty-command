# frozen_string_literal: true

RSpec.describe TTY::Command::Cmd, '::new' do
  it "requires at least command argument" do
    expect {
      TTY::Command::Cmd.new({})
    }.to raise_error(ArgumentError, /Cmd requires command argument/)
  end

  it "requires non empty command argument" do
    expect {
      TTY::Command::Cmd.new(nil)
    }.to raise_error(ArgumentError, /No command provided/)
  end

  it "accepts a command" do
    cmd = TTY::Command::Cmd.new(:echo)
    expect(cmd.command).to eq('echo')
    expect(cmd.argv).to eq([])
    expect(cmd.options).to eq({})
    expect(cmd.to_command).to eq('echo')
  end

  it "accepts a command as heredoc" do
    cmd = TTY::Command::Cmd.new <<-EOHEREDOC
      if [[ $? -eq 0]]; then
        echo "Bash it!"
      fi
    EOHEREDOC
    expect(cmd.argv).to eq([])
    expect(cmd.options).to eq({})
    expect(cmd.to_command).to eq([
      "      if [[ $? -eq 0]]; then",
      "        echo \"Bash it!\"",
      "      fi\n"
    ].join("\n"))
  end

  it "accepts command as [cmdname, arg1, ...]" do
    cmd = TTY::Command::Cmd.new(:echo, '-n', 'hello')
    expect(cmd.command).to eq('echo')
    expect(cmd.argv).to eq(['-n', 'hello'])
    expect(cmd.to_command).to eq('echo -n hello')
  end

  it "accepts command as [[cmdname, argv0], arg1, ...]" do
    cmd = TTY::Command::Cmd.new([:echo, '-n'], 'hello')
    expect(cmd.command).to eq('echo')
    expect(cmd.argv).to eq(['-n', 'hello'])
    expect(cmd.to_command).to eq('echo -n hello')
  end

  it "accepts command with environment as [cmdname, arg1, ..., opts]" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', env: {foo: 'bar'})
    expect(cmd.to_command).to eq(%{( export FOO=\"bar\" ; echo hello )})
  end

  it "accepts command with multiple environment keys" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', env: {foo: 'a', bar: 'b'})
    expect(cmd.to_command).to eq(%{( export FOO=\"a\" BAR=\"b\" ; echo hello )})
  end

  it "accepts command with environemnt string keys" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', env: {'FOO_bar' => 'a', bar: 'b'})
    expect(cmd.to_command).to eq(%{( export FOO_bar=\"a\" BAR=\"b\" ; echo hello )})
  end

  it "escapes environment values" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', env: {foo: 'abc"def'})
    expect(cmd.to_command).to eq(%{( export FOO=\"abc\\\"def\" ; echo hello )})
  end

  it "accepts environment as first argument" do
    cmd = TTY::Command::Cmd.new({'FOO' => true, 'BAR' => 1}, :echo, 'hello')
    expect(cmd.to_command).to eq(%{( export FOO=\"true\" BAR=\"1\" ; echo hello )})
  end

  it "runs command in specified directory" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', chdir: '/tmp')
    expect(cmd.to_command).to eq("cd /tmp && echo hello")
  end

  it "runs command in specified directory with environment" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', chdir: '/tmp', env: {foo: 'bar'})
    expect(cmd.to_command).to eq(%{cd /tmp && ( export FOO=\"bar\" ; echo hello )})
  end

  it "runs command as a user" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', user: 'piotrmurach')
    expect(cmd.to_command).to eq("sudo -u piotrmurach -- sh -c 'echo hello'")
  end

  it "runs command as a group" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', group: 'devs')
    expect(cmd.to_command).to eq("sg devs -c \\\"echo hello\\\"")
  end

  it "runs command as a user in a group" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', user: 'piotrmurach', group: 'devs')
    expect(cmd.to_command).to eq("sudo -u piotrmurach -- sh -c 'sg devs -c \\\"echo hello\\\"'")
  end

  it "runs command with umask" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', umask: '077')
    expect(cmd.to_command).to eq("umask 077 && echo hello")
  end

  it "runs command with umask, chdir" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', umask: '077', chdir: '/tmp')
    expect(cmd.to_command).to eq("cd /tmp && umask 077 && echo hello")
  end

  it "runs command with umask, chdir & user" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', umask: '077', chdir: '/tmp', user: 'piotrmurach')
    expect(cmd.to_command).to eq("cd /tmp && umask 077 && sudo -u piotrmurach -- sh -c 'echo hello'")
  end

  it "runs command with umask, user, chdir and env" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello', umask: '077', chdir: '/tmp', user: 'piotrmurach', env: {foo: 'bar'})
    expect(cmd.to_command).to eq(%{cd /tmp && umask 077 && ( export FOO=\"bar\" ; sudo -u piotrmurach FOO=\"bar\" -- sh -c 'echo hello' )})
  end

  it "provides unique identifier" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello')
    expect(cmd.uuid).to match(/^\w{8}$/)
  end

  it "converts command to hash" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello')
    expect(cmd.to_hash).to include({
      command: 'echo',
      argv: ['hello']
    })
  end

  it "escapes arguments that need escaping" do
    cmd = TTY::Command::Cmd.new(:echo, 'hello world')
    expect(cmd.to_hash).to include({
      command: 'echo',
      argv: ["hello\\ world"]
    })
  end

  it "escapes special characters in split arguments" do
    args = %w(git for-each-ref --format='%(refname)' refs/heads/)
    cmd = TTY::Command::Cmd.new(*args)
    expect(cmd.to_hash).to include({
      command: 'git',
      argv: ["for-each-ref", "--format\\=\\'\\%\\(refname\\)\\'", "refs/heads/"]
    })
  end
end
