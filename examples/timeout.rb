# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

cmd.execute("while test 1; do echo 'hello'; sleep 1; done", timeout: 5)
