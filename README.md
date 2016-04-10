# TTY::Command
[![Gem Version](https://badge.fury.io/rb/tty-command.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/tty-command.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/piotrmurach/tty-command/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-command/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/tty-command.svg?branch=master)][inchpages]

[gem]: http://badge.fury.io/rb/tty-command
[travis]: http://travis-ci.org/piotrmurach/tty-command
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-command
[coverage]: https://coveralls.io/github/piotrmurach/tty-command
[inchpages]: http://inch-ci.org/github/piotrmurach/tty-command

> Execute shell commands with pretty output logging and capture their stdout, stderr and exit status. Redirect stdin, stdout and stderr of each command to a file or a string.

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
  * [2.1 execute](#21-execute)
  * [2.2 Environment variables](#22-environment-variables)
  * [2.2 Command](#23-command)
  * [2.4 Options](#24-options)
    * [2.4.1 Current directory](#241-current-directory)
    * [2.4.2 Redirection](#242-redirection)
    * [2.4.3 Timeout](#243-timeout)
    * [2.4.4 User](#244-user)
    * [2.4.5 Group](#245-group)
    * [2.4.6 Umask](#246-umask)
  * [2.5 Result](#25-result)
    * [2.5.1 success?](#251-success)
    * [2.5.2 failure?](#252-failure)
    * [2.5.3 exited?](#253-exited)
* [3. Settings](#3-settings)
  * [3.1 Output](#31-output)

## 1. Usage

Create command runner:

```ruby
cmd = TTY::Command.new
```

And then, to run command and capture its stadout and stderr use `execute`:

```ruby
stdout, stderr = cmd.execute(:ls, '-la')
stdout, stderr = cmd.execute(:echo, 'hello')
```

You can check command status by calling `success?`, `failure?` or `exit_status` on result:

```ruby
result = cmd.execute(:echo, 'hello')
result.success?  # => true
result.failure?  # => false
result.exit_status # => 0
```

You can also provide custom redirections:

```ruby
cmd.execute(:echo, 'Hello!', :out => 'file.txt')
```

## 2. Interface

### 2.1 execute

The argument signature for `execute` is as follows:

`execute([env], command, [argv1, ...], [options])`

The env, command and options arguments are described below.

### 2.2 Environment variables

The environment variables need to be provided as a hash entries, that can be set directly as a first argument:

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

### 2.3 Command

To actually run a command, you need to provie the command name and one or more arguments to execute:

```ruby
cmd.execute(:echo, 'hello', 'world')
```

### 2.4 Options

When a hash is given in the last argument (options), it allows to specify a current directory, umask, user, group and and zero or more fd redirects for the child process.

#### 2.4.1 Current directory

To change directory in which the command is run pass the `:chidir` option:

```ruby
cmd.execute(:echo, 'hello', chdir: '/var/tmp')
```

#### 2.4.2 Redirection

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

Merge stderr into stdout

```ruby
cmd.execute(:ls, '-la', :stderr => :stdout)
cmd.execute(:ls, '-la', 2 => 1)
```

#### 2.4.3 Timeout

You can timeout command execuation by providing the `:timeout` option in seconds:

```ruby
cmd.execute("while test 1; sleep 1; done", timeout: 5)
```

Please run `examples/timeout.rb` to see timeout in action.

#### 2.4.4 User

To execute command as a given user do:

```ruby
cmd.execute(:echo, 'hello', user: 'piotr')
```

#### 2.4.5 Group

To execute command as part of group do:

```ruby
cmd.execute(:echo, 'hello', group: 'devs')
```

#### 2.4.6 Umask

To execute command with umask do:

```ruby
cmd.execute(:echo, 'hello', umask: '007')
```

### 2.5 Result

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

#### 2.5.1 success?

To check if command exited successfully use `success?`:

```ruby
result = cmd.execute(:echo, 'Hello')
result.success? # => true
```

#### 2.5.2 failure?

To check if command exited unsuccessfully use `failure?` or `failed?`:

```ruby
result = cmd.execute(:echo, 'Hello')
result.failure?  # => false
result.failed?   # => false
```

#### 2.5.3 exited?

To check if command run to complition use `exited?` or `complete?`:

```ruby
result = cmd.execute(:echo, 'Hello')
result.exited?    # => true
result.complete?  # => true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/tty-command. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Copyright

Copyright (c) 2016 Piotr Murach. See LICENSE for further details.
