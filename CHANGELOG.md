# Change log

## Unreleased

### Fixed
* Fix undesired persistence of environment variables in Ruby >= 3.0.0

## [v0.10.0] - 2020-10-22

### Changed
* Change :chdir option to escape directory location path
* Change gemspec to add metadata and remove test artefacts
* Change to update pastel dependency and restrict version to minor only
* Remove bundler as a dev dependency and relax rspec's upper boundary

### Fixed
* Fix Ruby 2.7 keyword conversion errors
* Fix error when environment variable contains % character

## [v0.9.0] - 2019-09-28

### Changed
* Change gemspec to require Ruby >= 2.0.0

## [v0.8.2] - 2018-08-07

### Changed
* Change gemspec to load only required files

### Fixed
* Fix issue with Ruby greater than 2.5.0 displaying thread error traceback by default

## [v0.8.1] - 2018-05-20

### Changed
* Change ProcessRunner#write_stream to handle all writing logic

## [v0.8.0] - 2018-04-22

### Added
* Add :output_only_on_error option by Iulian Onofrei(@revolter)
* Add :verbose flag to toggle warnings

### Changed
* Change ProcessRunner to use waitpid2 api for direct status
* Change ProcessRunner stdout & stderr reading to use IO.select and be non-blocking

### Fixed
* Fix :timeout to raise when long running without input or output
* Fix ProcessRunner to ensure no zombie processes on timeouts

## [v0.7.0] - 2017-11-19

### Added
* Add :binmode option to allow configuring input & ouput as binary
* Add :pty option to allow runnig commands in PTY(pseudo terminal)

### Changed
* Change Command to remove threads synchronization to leave it up to client to handle
* Change Cmd to allow updating options
* Change Command to accept options for all commands such as :timeout, :binmode etc...
* Change Execute to ChildProcess module
* Change ChildProcess to skip spawn redirect close options on Windows platform
* Change to enforce UTF-8 encoding for process pipes to be cross platform
* Change ProcessRunner to stop rescuing runtime failures
* Change to stop mutating String instances

### Fixed
* Fix ProcessRunner threads deadlocking on exclusive mutex
* Fix :timeout option to raise TimeoutExceeded error
* Fix test suite to work on Windows
* Fix Cmd arguments escaping

## [v0.6.0] - 2017-07-22

### Added
* Add runtime property to command result
* Add ability to merge multiple redirects

### Changed
* Change to make all strings immutable
* Change waiting for pid to recover when already dead

### Fix
* Fix redirection to instead of redirecting to parent process, redirect to child process. And hence allow for :out => :err redirection to work with output logging.

## [v0.5.0] - 2017-07-16

### Added
* Add :signal option for timeout
* Add :input option for handling stdin input
* Add ability for Command#run to specify a callback that is invoked whenever stdout or stderr receive output
* Add Command#wait for polling a long running script for matching output

### Changed
* Change ProcessRunner to immediately sync write pipe
* Change ProcessRunner to write to stdin stream when writable

### Fixed
* Fix quiet printer write call by @jamesepatrick
* Fix to correctly close all pipe ends between parent and child process
* Fix timeout behaviour for writable and readable streams

## [v0.4.0] - 2017-02-22

### Changed
* Remove automatic insertion of semicolons on line breaks and fix issue #27

## [v0.3.3] - 2017-02-10

### Changed
* Update deprecated Fixnum class to Integer for Ruby 2.4 compatability by Edmund Larden(@admund)
* Remove self extension from Execute

## [v0.3.2] - 2017-02-06

### Fixed
* Fix File namespacing

## [v0.3.1] - 2017-01-22

### Fixed
* Fix top level File constant

## [v0.3.0] - 2017-01-13

### Added
* Add ability to enumerate Result output
* Add #record_saparator for specifying delimiter for enumeration

### Changed
* Change Abstract printer to separate arguments out
* Change Cmd to prevent modifications
* Change pastel dependency version

## [v0.2.0] - 2016-07-03

### Added
* Add ruby interperter helper

### Fixed
* Fix multibyte content truncation for streams by Ondrej Moravcik(@ondra-m)

## [v0.1.0] - 2016-05-29

* Initial implementation and release

[v0.10.0]: https://github.com/piotrmurach/tty-command/compare/v0.9.0...v0.10.0
[v0.9.0]: https://github.com/piotrmurach/tty-command/compare/v0.8.2...v0.9.0
[v0.8.2]: https://github.com/piotrmurach/tty-command/compare/v0.8.1...v0.8.2
[v0.8.1]: https://github.com/piotrmurach/tty-command/compare/v0.8.0...v0.8.1
[v0.8.0]: https://github.com/piotrmurach/tty-command/compare/v0.7.0...v0.8.0
[v0.7.0]: https://github.com/piotrmurach/tty-command/compare/v0.6.0...v0.7.0
[v0.6.0]: https://github.com/piotrmurach/tty-command/compare/v0.5.0...v0.6.0
[v0.5.0]: https://github.com/piotrmurach/tty-command/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/piotrmurach/tty-command/compare/v0.3.3...v0.4.0
[v0.3.3]: https://github.com/piotrmurach/tty-command/compare/v0.3.2...v0.3.3
[v0.3.2]: https://github.com/piotrmurach/tty-command/compare/v0.3.1...v0.3.2
[v0.3.1]: https://github.com/piotrmurach/tty-command/compare/v0.3.0...v0.3.1
[v0.3.0]: https://github.com/piotrmurach/tty-command/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/piotrmurach/tty-command/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/piotrmurach/tty-command/compare/v0.1.0
