# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

cmd.run(:ls, :out => 'ls_sample')
