# Change log

## [v0.5.0] - 2017-07-xx

### Added
* Add :signal option for timeout
* Add :data option for handling stdin input

### Changed
* Change ProcessRunner to immediately sync write pipe

### Fixed
* Fix quiet printer write call by @jamesepatrick
* Fix to correctly close all pipe ends between parent and child process

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

[v0.4.0]: https://github.com/piotrmurach/tty-command/compare/v0.3.3...v0.4.0
[v0.3.3]: https://github.com/piotrmurach/tty-command/compare/v0.3.2...v0.3.3
[v0.3.2]: https://github.com/piotrmurach/tty-command/compare/v0.3.1...v0.3.2
[v0.3.1]: https://github.com/piotrmurach/tty-command/compare/v0.3.0...v0.3.1
[v0.3.0]: https://github.com/piotrmurach/tty-command/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/piotrmurach/tty-command/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/piotrmurach/tty-command/compare/v0.1.0
