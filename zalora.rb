require 'thor'
require 'nokogiri'

class ZaloraCLI < Thor
  long_desc <<-LONGDESC
    Zalora cli toolkit
    require hub
  LONGDESC
  no_commands do
    def shop_dir
      '/Users/zalora/shop'
    end

    def docker_dir
      '/Users/zalora/shop-docker'
    end

    def curl(host)
      "curl -L -c .cookies -b .cookies -s #{host}"
    end
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

  desc 'deploy staging', 'deploy a branch to staging'
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

  desc 'pr <SHOP-12345>', 'create pull request and notify reviewer'
  def pr(ticket)
    `cd #{shop_dir}`
    `git checkout #{ticket}`
    ticket_info = query(ticket) 
    puts ticket_info
    puts `hub pull-request -b rc -m '#{ticket_info[:summary]}'`
    `cd -`
  end

  desc 'login jira <email>', 'login a user with sso'
  def login_jira(email)
    password = STDIN.getpass('Password: ')
    command=curl "-X POST --data-urlencode username='#{email}' --data-urlencode password='#{password}' 'https://zalora.atlassian.net/login' -o /dev/null"
    system command
  end

  desc 'login github', 'login into github using hub'
  def login_github
  end

  desc 'query <SHOP-12345>', 'query info about a ticket'
  def query(ticket)
    command = curl("'https://zalora.atlassian.net/browse/#{ticket}'")
    response = %x(#{command})
    html_doc = Nokogiri::HTML(response)
    ticket_title = html_doc.xpath("//*[@id='summary-val']").text
    {
      :name => ticket,
      :summary => ticket_title
    }
  end
end

ZaloraCLI.start(ARGV)
