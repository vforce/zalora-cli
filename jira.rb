require 'nokogiri'
require 'json'
require './zalora_cli'

class Jira < Thor
  include ZaloraCLI

  ISSUE_BASE_URL = "https://zalora.atlassian.net/rest/api/2/issue"

  JIRA_TRANS_AWAITING_REVIEW = "Awaiting Review"

  no_commands do
    def get_transitions(ticket)
      command = curl("'#{base_url}/issue/#{ticket}/transitions'")
      transitions = JSON.parse(`#{command}`)['transitions']
      transitions_map = {}
      transitions.each do |x| 
        transitions_map[x['id']] = x['name']
      end
      transitions_map
    end

    def transistTicket(ticket, stateId)
      body = {
        transition: {
          id: stateId
        }
      }
      command = curl("-X POST -H 'Content-Type: application/json' -d '#{body.to_json}' '#{ISSUE_BASE_URL}/#{ticket}/transitions'")
      puts command
      puts `#{command}`
    end
  end

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
    transitions_map = get_transitions(ticket)
    response[:transitions] = transitions_map
    puts response
    response
  end

  desc 'transit <ticket> <state>', 'transit a ticket to desire state'
  def transit(ticket, state)
    transitions = get_transitions(ticket)
    transitions.each do |id, name|
      if state.upcase == name.upcase
        transistTicket(ticket, id)
        exit 
      end
    end
    puts "Invalid state. Valid states are #{transitions}"
  end

end
