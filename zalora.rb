require 'thor'
require 'nokogiri'

class ZaloraCLI < Thor
  no_commands do
    def shop_dir
      '~/shop'
    end

    def docker_dir
      '~/shop-docker'
    end

    def curl(host)
      "curl -L -c .cookies -b .cookies -s #{host}"
    end
  end

  desc 'deploy staging', 'deploy a branch to staging'
  def deploy_staging(branch)
  end

  desc 'generate <sg>', 'regenerate all in local and docker'
  def generate(venture)
    system "php #{shop_dir}/tools/generate_all.php"
    system "rm #{shop_dir}/alice/local/config/config.php"
    system "#{docker_dir}/generate.sh config/all #{venture}"
  end

  desc 'pr <SHOP-12345>', 'create pull request and notify reviewer'
  def pr(ticket)
    
  end

  desc 'login <email>', 'login a user with sso'
  def login(email)
    password = STDIN.getpass('Password: ')
    command=curl "-X POST --data-urlencode username='#{email}' --data-urlencode password='#{password}' 'https://zalora.atlassian.net/login' -o /dev/null"
    system command
  end

  desc 'query <SHOP-12345>', 'query info about a ticket'
  def query(ticket)
    command = curl("'https://zalora.atlassian.net/browse/#{ticket}'")
    response = %x(#{command})
    html_doc = Nokogiri::HTML(response)
    ticket_title = html_doc.xpath("//*[@id='summary-val']").text
    puts "Ticket number: #{ticket}"
    puts "Ticket summary: #{ticket_title}"
  end
end

ZaloraCLI.start(ARGV)
