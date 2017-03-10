require 'thor'
require './zalora_cli'

#class to manage ssh to remote servers so that dev doesn't 
#need to remember ssh commands
class Ssh < Thor
  desc 'db <staging|live> <sg>', "ssh to a venture's on staging"
  def db(env, venture)
    if env == 'staging'
      if venture == 'sg'
        exec "ssh #{ENV['user']}@web1.staging.sg.zalora.net -t '/nix/store/58nkkb3r0nfad92hhchb3xyzgr7p1nhy-mariadb-10.0.15/bin/mysql -ubob_staging -hdb-master.int.staging.sg.zalora.net -Dbob_staging_sg'"
      else
        exec "ssh #{ENV['user']}@db-master.staging.#{venture}.zalora.net -t 'mysql -uroot -Dbob_staging_#{venture}'"
      end
    elsif env == 'live'
    else
      puts "Invalid environment. Valid environments are staging | live"
    end
  end
end
