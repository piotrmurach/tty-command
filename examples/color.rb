require 'tty-command'

cmd = TTY::Command.new

path = File.expand_path("../spec/unit/cmd_spec.rb", __dir__)

cmd.run "bundle exec rspec #{path}"
