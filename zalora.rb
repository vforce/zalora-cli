require 'thor'
require 'thor/group'
require './jira'
require './dev'

class Zalora < Thor
  desc 'dev <subcommand>', 'dev related commands'
  subcommand 'dev', Dev

  desc 'jira <subcommand>', 'jira related commands'
  subcommand 'jira', Jira
end


Zalora.start(ARGV)
