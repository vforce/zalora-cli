#!/usr/bin/ruby
require 'dotenv/load'
require 'thor'
require 'thor/group'
require './jira'
require './dev'
require './ssh'

class Zalora < Thor
  desc 'dev <subcommand>', 'dev related commands'
  subcommand 'dev', Dev

  desc 'jira <subcommand>', 'jira related commands'
  subcommand 'jira', Jira

  desc 'ssh <subscommand>', 'ssh related commands'
  subcommand 'ssh', Ssh
end


Zalora.start(ARGV)
