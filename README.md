# TTY::Command [![Gitter](https://badges.gitter.im/Join%20Chat.svg)][gitter]
[![Gem Version](https://badge.fury.io/rb/tty-command.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/tty-command.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/piotrmurach/tty-command/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-command/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/tty-command.svg?branch=master)][inchpages]

[gitter]: https://gitter.im/piotrmurach/tty
[gem]: http://badge.fury.io/rb/tty-command
[travis]: http://travis-ci.org/piotrmurach/tty-command
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-command
[coverage]: https://coveralls.io/github/piotrmurach/tty-command
[inchpages]: http://inch-ci.org/github/piotrmurach/tty-command

> Execute external commands with pretty output logging and capture stdout, stderr and exit status. Redirect stdin, stdout and stderr of each command to a file or a string.

**TTY::Command** provides independent command execution component for [TTY](https://github.com/piotrmurach/tty) toolkit.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-command'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-command

## Contents

* [1. Usage](#1-usage)
* [2. Interface](#2-interface)
  * [2.1 Execute](#21-execute)
  * [2.2 Execute!](#22-execute)
  * [2.3 Environment variables](#23-environment-variables)
  * [2.3 Command](#24-command)
  * [2.5 Options](#25-options)
    * [2.5.1 Current directory](#251-current-directory)
    * [2.5.2 Redirection](#252-redirection)
    * [2.5.3 Timeout](#253-timeout)
    * [2.5.4 User](#254-user)
    * [2.5.5 Group](#255-group)
    * [2.5.6 Umask](#256-umask)
  * [2.6 Result](#26-result)
    * [2.6.1 success?](#261-success)
    * [2.6.2 failure?](#262-failure)
    * [2.6.3 exited?](#263-exited)
  * [2.7 Output Logging](#27-output-logging)
    * [2.7.1 Custom Printer](#271-custom-printer)
* [3. Example](#3-example)

## 1. Usage

Create command instance:

```ruby
cmd = TTY::Command.new
```

And then, to run command and capture its stadout and stderr use `execute`:

```ruby
out, err = cmd.execute('ls -la')
out, err = cmd.execute('echo Hello!')
```

You can also split command into arguments like so:

```ruby
out, err = cmd.execute(:ls, '-la')
out, err = cmd.execite(:echo, 'Hello!')
```

You can also provide custom redirections:

```ruby
cmd.execute(:echo, 'Hello!', :out => 'file.txt')
```

## 2. Interface

### 2.1 Execute

Execute starts the specified command and waits for it to complete.

The argument signature for `execute` is as follows:

`execute([env], command, [argv1, ...], [options])`

The `env`, `command` and `options` arguments are described in the following sections.

The command executes successfully and returns result, if the command exits with a zero exit status, and has no problems handling stdin, stdout, and stderr.

If the command fails to execute or doesn't complete successfully, an `TTY::Command::ExitError` is raised.

For example, to display file contents:

```ruby
cmd.execute('cat file.txt')
```

When command is run without raising `TTY::Command::ExitError`, a `TTY::Command::Result` is returned that records stdout and stderr:

```ruby
out, err = cmd.execute('date')
puts "The date is #{out}"
# => "The date is Tue 10 May 2016 22:30:15 BST\n"
```

### 2.2 Execute!

You can also use `execute!` to run a command that will raise an error `TTY::Command::ExitError` when the command exits with non-zero exit code: 

```ruby
cmd.execute!('cat file')
# => raises TTY::Command::ExitError
# Executing `cat file` failed with
#  exit status: 1
#  ...
```

The `ExitError` message will include:
  * the name of command executed
  * the exit status
  * stdout bytes
  * stderr bytes

### 2.3 Environment variables

The environment variables need to be provided as hash entries, that can be set directly as a first argument:

```ruby
cmd.execute({'RAILS_ENV' => 'PRODUCTION'}, :rails, 'server')
```

or as an option with `:env` key:

```ruby
cmd.execute(:rails, 'server', env: {rails_env: :production})
```

When a value in env is nil, the variable is unset in the child process:

```ruby
cmd.execute(:echo, 'hello', env: {foo: 'bar', baz: nil})
```

### 2.4 Command

To actually run a command, you need to provie the command name and one or more arguments to execute:

```ruby
cmd.execute(:echo, 'hello', 'world')
```

### 2.5 Options

When a hash is given in the last argument (options), it allows to specify a current directory, umask, user, group and and zero or more fd redirects for the child process.

#### 2.5.1 Current directory

To change directory in which the command is run pass the `:chidir` option:

```ruby
cmd.execute(:echo, 'hello', chdir: '/var/tmp')
```

#### 2.5.2 Redirection

The streams can be redirected using hash keys `:in`, `:out`, `:err`, a fixnum, an IO and array. The keys specify a given file descriptor for the child process.

You can specify a filename for redirection as a hash value:

```ruby
cmd.execute(:ls, :in => "/dev/null")   # read mode
cmd.execute(:ls, :out => "/dev/null")  # write mode
cmd.execute(:ls, :err => "log")        # write mode
cmd.execute(:ls, [:out, :err] => "/dev/null") # write mode
cmd.execute(:ls, 3 => "/dev/null")     # read mode
```

You can also provide actual file descriptor for redirection:

```ruby
cmd.execute(:cat, :in => open('/etc/passwd'))
```

For example, to merge stderr into stdout you would do:

```ruby
cmd.execute(:ls, '-la', :stderr => :stdout)
cmd.execute(:ls, '-la', 2 => 1)
```

#### 2.5.3 Timeout

You can timeout command execuation by providing the `:timeout` option in seconds:

```ruby
cmd.execute("while test 1; sleep 1; done", timeout: 5)
```

Please run `examples/timeout.rb` to see timeout in action.

#### 2.5.4 User

To execute command as a given user do:

```ruby
cmd.execute(:echo, 'hello', user: 'piotr')
```

#### 2.5.5 Group

To execute command as part of group do:

```ruby
cmd.execute(:echo, 'hello', group: 'devs')
```

#### 2.5.6 Umask

To execute command with umask do:

```ruby
cmd.execute(:echo, 'hello', umask: '007')
```

### 2.6 Result

Each time you execute command the stdout and stderro are captured and return as result. The result can be examined directly by casting it to tuple:

```ruby
out, err = cmd.execute(:echo, 'Hello')
```

However, if you want to you can defer reading:

```ruby
result = cmd.execute(:echo, 'Hello')
result.out
result.err
```

#### 2.6.1 success?

To check if command exited successfully use `success?`:

```ruby
result = cmd.execute(:echo, 'Hello')
result.success? # => true
```

#### 2.6.2 failure?

To check if command exited unsuccessfully use `failure?` or `failed?`:

```ruby
result = cmd.execute(:echo, 'Hello')
result.failure?  # => false
result.failed?   # => false
```

#### 2.6.3 exited?

To check if command run to complition use `exited?` or `complete?`:

```ruby
result = cmd.execute(:echo, 'Hello')
result.exited?    # => true
result.complete?  # => true
```

### 2.7 Output Logging

By default when command is executed, the command itself with all arguments as well as command's output are printed to `stdout` using the `:pretty` printer. If you wish to change printer you can do so by passing `:printer` option out of

* `:null` - no output
* `:pretty` - colorful output,
* `:progress` - minimal output with green dot for success and F for failure
* `:quiet` - only output actual command stdout and stderr

to command like so:

```ruby
cmd = TTY::Command.new(printer: :progress)
```

By default the printers log to `stdout` but this can be changed by passing object that responds to `<<` message:

```ruby
logger = Logger.new('dev.log')
cmd = TTY::Command.new(output: output)
```

You can force printer to always in print in color by passing `:color` option:

```ruby
cmd = TTY::Command.new(color: true)
```

#### 2.7.1 Custom printer

If the built-in printers do not meet your requirements you can create your own. Add the very minimum you need to specify the `write` method that will be called during the lifecycle of command execution:

```ruby
CustomPrinter < TTY::Command::Printers::Abstract
  def write(message)
    puts message
  end
end

printer = CustomPrinter

cmd = TTY::Command.new(printer: printer)
```

## 3. Example

Here's a slightly more elaborate example to illustrate how tty-command can improve on plain old shell scripts. This example installs a new version of Ruby on an Ubuntu machine.

```ruby
cmd = TTY::Command.new

# dependencies
cmd.execute "apt-get -y install build-essential checkinstall"

# fetch ruby if necessary
if !File.exists?("ruby-2.3.0.tar.gz")
  puts "Downloading..."
  cmd.execute "wget http://ftp.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz"
  cmd.execute "tar xvzf ruby-2.3.0.tar.gz"
end

# now install
Dir.chdir("ruby-2.3.0") do
  puts "Building..."
  cmd.execute "./configure --prefix=/usr/local"
  cmd.execute "make"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/tty-command. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Copyright

Copyright (c) 2016 Piotr Murach. See LICENSE for further details.
