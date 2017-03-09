require './zalora_cli'

class Dev < Thor
  include ZaloraCLI

  no_commands do
    def run_sql_config(venture, key, value)
      `mysql -uroot -D bob_live_#{venture} <<< "update configuration set config_value='#{value}' where config_key='#{key}'"`
    end

    def run_worker
      Dir.chdir(docker_dir) {
        system "./worker.sh"
      }
    end

    def run_solr
      Dir.chdir(docker_dir) {
        system "./solrImport.sh"
      }
    end
  end

  desc 'init', 'TODO: install needed dependencies'
  def init
  end

  desc 'refreshdb', 'TODO: refresh local db'
  def refreshdb(venture)
    command = curl "https://dumpoo.zalora.com/job/bob_live_#{venture}/"
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

  desc 'change_adapter <mysql|memcached> <sg>', 'chane adapter of alice.dev'
  def change_adapter(adapter, venture)
    if adapter != 'mysql' && adapter != 'memcached'
      puts "Invalid adapter. Valid adapters are 'sql' or 'memcached'"
      exit 1
    end
    s = ''
    if adapter == 'sql'
      s = 'MySqlAdapter'
      run_sql_config(venture, 'messaging_kv_mysql_hostname', 'host-ip')
      run_sql_config(venture, 'messaging_kv_mysql_database', "bob_live_#{venture}")
      run_sql_config(venture, 'messaging_kv_mysql_username', ENV['mysql_username'])
      run_sql_config(venture, 'messaging_kv_mysql_password', ENV['mysql_password'])
    else
      s = 'MemcachedAdapter'
      run_sql_config(venture, 'messaging_kv_memcached_hostname', "memcached.dev:11211")
    end
    `sed -i 's/"local.storage"=>".*Adapter"/"local.storage"=>"#{s}"/g' #{docker_dir}/env/config.php`
    `sed -i 's/"remote.storage"=>".*Adapter"/"remote.storage"=>"#{s}"/g' #{docker_dir}/env/config.php`
    `cp #{docker_dir}/env/config.php #{shop_dir}/tools`
    run_sql_config(venture, 'messaging_kv_adapter', adapter)
    generate(venture)
    if adapter == 'memcached'
      puts "Settings changed, but you should rerun worker & solr import"
    end
    run_worker
    run_solr
  end

  def mail(type)
  end
end
