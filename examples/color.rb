# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

cmd.run :echo, "\e[35mhello \e[34mworld\e[0m"
