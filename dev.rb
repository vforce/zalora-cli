require './zalora_cli'

class Dev < Thor
  include ZaloraCLI

  no_commands do
  end

  desc 'init', 'TODO: install needed dependencies'
  def init
  end

  desc 'refreshdb', 'TODO: refresh local db'
  def refreshdb(venture)
  end


  desc 'start', 'start development environment'
  def start
    Dir.chdir(docker_dir) {
      system "./watch-code.sh"
    }
  end

  desc 'switch <sg>', 'switch venture'
  def switch(venture)
    Dir.chdir(docker_dir) {
      system "./switch-country.sh #{venture} && ./generate.sh config/all #{venture} && ./worker.sh && ./solrImport.sh"
    }
  end

  desc 'deploy_staging <SHOP-13441>', 'generate hash code to deploy to staging'
  def deploy_staging(branch)
    exit 1 if branch == 'master' || branch == 'rc'
    Dir.chdir(shop_dir) {
      minify_branch = branch + '+minify'
      system "git checkout #{branch}"
      system "git branch -D #{minify_branch}"
      system "git checkout -b #{minify_branch}"
      system "php tools/generate_all.php"
      system "php alice/dev/deploy.php"
      system "git add ."
      system "git commit -m '#{branch}: minify and deploy to staging'"
      system "git push -f origin #{minify_branch}"
      puts `git log $branch_name | head -1 | sed 's/commit //g'`
      puts "clean up ..."
      `rm alice/local/config/config.php`
      system "git checkout #{branch}"
    }
  end

  desc 'generate <sg>', 'regenerate all in local and docker'
  def generate(venture)
    system "php #{shop_dir}/tools/generate_all.php"
    system "rm #{shop_dir}/alice/local/config/config.php"
    system "#{docker_dir}/generate.sh config/all #{venture}"
  end


  desc 'login_jira <email>', 'login a user with sso'
  def login_jira(email)
    password = STDIN.getpass('Password: ')
    command = curl "-X POST --data-urlencode username='#{email}' --data-urlencode password='#{password}' 'https://zalora.atlassian.net/login' -o /dev/null"
    system command
  end
end
