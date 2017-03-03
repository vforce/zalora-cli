require './zalora_cli'

class Jira < Thor
  include ZaloraCLI

  desc 'pr <SHOP-12345>', 'create pull request and notify reviewer'
  def pr(ticket)
    Dir.chdir(shop_dir) {
      ticket_info = query(ticket) 
      if ticket_info.nil? || ticket_info[:summary] == ''
        puts "Unable to get ticket summary, may be you didn't login?"
        exit 1
      end
      `git checkout #{ticket}`
      `git push origin #{ticket}`
      puts ticket_info
      puts `hub pull-request -b rc -m '#{ticket_info[:summary]}'`
    }
  end

  desc 'query <SHOP-12345>', 'query info about a ticket'
  def query(ticket)
    command = curl("'https://zalora.atlassian.net/browse/#{ticket}'")
    response = %x(#{command})
    html_doc = Nokogiri::HTML(response)
    ticket_title = html_doc.xpath("//*[@id='summary-val']").text
    response = { :name => ticket, :summary => ticket_title }
    transitions = get_transitions(ticket)
    transition_names = transitions.map {|x| x['name']}
    response[:transitions] = transition_names
    puts response
    response
  end
end
