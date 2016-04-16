# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

cmd.execute(:ls, :out => 'ls_sample')
