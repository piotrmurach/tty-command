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

> Run external commands with pretty output logging and capture stdout, stderr and exit status. Redirect stdin, stdout and stderr of each command to a file or a string.

**TTY::Command** provides independent command execution component for [TTY](https://github.com/piotrmurach/tty) toolkit.

## Motivation

Complex software projects aren't just a single app. These projects usually spawn dozens or hundreds of supplementary standalone scripts which are just as important as the app itself. Examples include - data validation, deployment, monitoring, database maintenance, backup & restore, configuration management, crawling, ETL, analytics, log file processing, custom reports, etc. One of the contributors to **TTY::Command** counted 222 scripts in the `bin` directory for his startup.

Why should we be handcuffed to `sh` or `bash` for these scripts when we could be using Ruby? Ruby is easier to write and more fun, and we gain a lot by using a better language. It's nice for everyone to just use Ruby everywhere.

**TTY::Command** tries to add value in other ways. It'll halt automatically if a command fails. It's easy to get verbose or quiet output as appropriate, or even capture output and parse it with Ruby. Escaping arguments is a breeze. These are all areas where traditional shell scripts tend to fall flat.

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
  * [2.1. Run](#21-run)
  * [2.2. Run!](#22-run)
  * [2.3. Test](#23-test)
  * [2.4. Logging](#24-logging)
  * [2.5. Dry run](#25-dry-run)
  * [2.6. Ruby interpreter](#26-ruby-interpreter)
* [3. Advanced Interface](#3-advanced-interface)
  * [3.1. Environment variables](#31-environment-variables)
  * [3.2. Options](#32-options)
    * [3.2.1. Current directory](#321-current-directory)
    * [3.2.2. Redirection](#322-redirection)
    * [3.2.3. Timeout](#323-timeout)
    * [3.2.4. User](#324-user)
    * [3.2.5. Group](#325-group)
    * [3.2.6. Umask](#326-umask)
  * [3.3. Result](#33-result)
    * [3.3.1. success?](#331-success)
    * [3.3.2. failure?](#332-failure)
    * [3.3.3. exited?](#333-exited)
  * [3.4. Custom printer](#34-custom-printer)
* [4. Example](#4-example)

## 1. Usage

Create a command instance and then run some commands:

```ruby
cmd = TTY::Command.new
cmd.run('ls -la')
cmd.run('echo Hello!')
```

Note that `run` will throw an exception if the command fails. This is already an improvement over ordinary shell scripts, which just keep on going when things go bad. That usually makes things worse.

You can use the return value to capture stdout and stderr:

```ruby
out, err = cmd.run('cat ~/.bashrc | grep alias')
```

Instead of using a plain old string, you can break up the arguments and they'll get escaped if necessary:

```ruby
path = "hello world"
FileUtils.touch(path)
cmd.run("sum #{path}")  # this will fail due to bad escaping
cmd.run("sum", path)    # this gets escaped automatically
```

## 2. Interface

### 2.1 Run

Run starts the specified command and waits for it to complete.

The argument signature of `run` is as follows:

`run([env], command, [argv1, ...], [options])`

The `env`, `command` and `options` arguments are described in the following sections.

For example, to display file contents:

```ruby
cmd.run('cat file.txt')
```

If the command succeeds, a `TTY::Command::Result` is returned that records stdout and stderr:

```ruby
out, err = cmd.run('date')
puts "The date is #{out}"
# => "The date is Tue 10 May 2016 22:30:15 BST\n"
```

If the command fails (with a non-zero exit code), a `TTY::Command::ExitError` is raised. The `ExitError` message will include:

  * the name of command executed
  * the exit status
  * stdout bytes
  * stderr bytes

If the error output is very long, the stderr may contain only a prefix, number of omitted bytes and suffix.

### 2.2 Run!

If you expect a command to fail occasionally, use `run!` instead. Then you can detect failures and respond appropriately. For example:

```ruby
if cmd.run!('which xyzzy').failure?
  cmd.run('brew install xyzzy')
end
```

### 2.3 Test

To simulate classic bash test command you case use `test` method with expression to check as a first argument:

```ruby
if cmd.test '-e /etc/passwd'
  puts "Sweet..."
else
  puts "Ohh no! Where is it?"
  exit 1
end
```

### 2.4 Logging

By default, when a command is run, the command and the output are printed to `stdout` using the `:pretty` printer. If you wish to change printer you can do so by passing a `:printer` option:

* `:null` - no output
* `:pretty` - colorful output
* `:progress` - minimal output with green dot for success and F for failure
* `:quiet` - only output actual command stdout and stderr

like so:

```ruby
cmd = TTY::Command.new(printer: :progress)
```

By default the printers log to `stdout` but this can be changed by passing an object that responds to `<<` message:

```ruby
logger = Logger.new('dev.log')
cmd = TTY::Command.new(output: output)
```

You can force the printer to always in print in color by passing the `:color` option:

```ruby
cmd = TTY::Command.new(color: true)
```

### 2.5 Dry run

Sometimes it can be useful to put your script into a "dry run" mode that prints commands without actually running them. To simulate execution of the command use the `:dry_run` option:

```ruby
cmd = TTY::Command.new(dry_run: true)
cmd.run(:rm, 'all_my_files')
# => [123abc] (dry run) rm all_my_files
```

To check what mode the command is in use the `dry_run?` query helper:

```ruby
cmd.dry_run? # => true
```

### 2.6 Ruby interpreter

**TTY::Command** provides a helper for running comannds with Ruby interpreter:

```ruby
cmd.ruby %q{-e "puts 'Hello world'"}
```

## 3. Advanced Interface

### 3.1 Environment variables

The environment variables need to be provided as hash entries, that can be set directly as a first argument:

```ruby
cmd.run({'RAILS_ENV' => 'PRODUCTION'}, :rails, 'server')
```

or as an option with `:env` key:

```ruby
cmd.run(:rails, 'server', env: {rails_env: :production})
```

When a value in env is nil, the variable is unset in the child process:

```ruby
cmd.run(:echo, 'hello', env: {foo: 'bar', baz: nil})
```

### 3.2 Options

When a hash is given in the last argument (options), it allows to specify a current directory, umask, user, group and and zero or more fd redirects for the child process.

#### 3.2.1 Current directory

To change directory in which the command is run pass the `:chidir` option:

```ruby
cmd.run(:echo, 'hello', chdir: '/var/tmp')
```

#### 3.2.2 Redirection

The streams can be redirected using hash keys `:in`, `:out`, `:err`, a fixnum, an IO and array. The keys specify a given file descriptor for the child process.

You can specify a filename for redirection as a hash value:

```ruby
cmd.run(:ls, :in => "/dev/null")   # read mode
cmd.run(:ls, :out => "/dev/null")  # write mode
cmd.run(:ls, :err => "log")        # write mode
cmd.run(:ls, [:out, :err] => "/dev/null") # write mode
cmd.run(:ls, 3 => "/dev/null")     # read mode
```

You can also provide actual file descriptor for redirection:

```ruby
cmd.run(:cat, :in => open('/etc/passwd'))
```

For example, to merge stderr into stdout you would do:

```ruby
cmd.run(:ls, '-la', :stderr => :stdout)
cmd.run(:ls, '-la', 2 => 1)
```

#### 3.2.3 Timeout

You can timeout command execuation by providing the `:timeout` option in seconds:

```ruby
cmd.run("while test 1; sleep 1; done", timeout: 5)
```

Please run `examples/timeout.rb` to see timeout in action.

#### 3.2.4 User

To run command as a given user do:

```ruby
cmd.run(:echo, 'hello', user: 'piotr')
```

#### 3.2.5 Group

To run command as part of group do:

```ruby
cmd.run(:echo, 'hello', group: 'devs')
```

#### 3.2.6 Umask

To run command with umask do:

```ruby
cmd.run(:echo, 'hello', umask: '007')
```

### 3.3 Result

Each time you run command the stdout and stderr are captured and return as result. The result can be examined directly by casting it to tuple:

```ruby
out, err = cmd.run(:echo, 'Hello')
```

However, if you want to you can defer reading:

```ruby
result = cmd.run(:echo, 'Hello')
result.out
result.err
```

#### 3.3.1 success?

To check if command exited successfully use `success?`:

```ruby
result = cmd.run(:echo, 'Hello')
result.success? # => true
```

#### 3.3.2 failure?

To check if command exited unsuccessfully use `failure?` or `failed?`:

```ruby
result = cmd.run(:echo, 'Hello')
result.failure?  # => false
result.failed?   # => false
```

#### 3.3.3 exited?

To check if command ran to completion use `exited?` or `complete?`:

```ruby
result = cmd.run(:echo, 'Hello')
result.exited?    # => true
result.complete?  # => true
```

### 3.4 Custom printer

If the built-in printers do not meet your requirements you can create your own. At the very minimum you need to specify the `write` method that will be called during the lifecycle of command execution:

```ruby
CustomPrinter < TTY::Command::Printers::Abstract
  def write(message)
    puts message
  end
end

printer = CustomPrinter

cmd = TTY::Command.new(printer: printer)
```

## 4. Example

Here's a slightly more elaborate example to illustrate how tty-command can improve on plain old shell scripts. This example installs a new version of Ruby on an Ubuntu machine.

```ruby
cmd = TTY::Command.new

# dependencies
cmd.run "apt-get -y install build-essential checkinstall"

# fetch ruby if necessary
if !File.exists?("ruby-2.3.0.tar.gz")
  puts "Downloading..."
  cmd.run "wget http://ftp.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz"
  cmd.run "tar xvzf ruby-2.3.0.tar.gz"
end

# now install
Dir.chdir("ruby-2.3.0") do
  puts "Building..."
  cmd.run "./configure --prefix=/usr/local"
  cmd.run "make"
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
