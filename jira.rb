require 'json'
require './zalora_cli'
require 'pp'

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
      url = `hub pull-request -b rc -m '#{ticket_info[:summary]}'`
      puts url
      transit(ticket, 'Awaiting Review')
      notify(ticket, "Hi [~#{ticket_info[:reviewer]}], please review my ticket at: #{url}. Thanks")
    }
  end

  desc 'query <SHOP-12345>', 'query info about a ticket'
  def query(ticket)
    command = curl_json("'#{ISSUE_BASE_URL}/#{ticket}'")
    response = %x(#{command})
    data = JSON.parse(response)
    response = { 
      :name => data['key'],
      :summary => data['fields']['summary'],
      :reviewer => data['fields']['customfield_10204']['key']
    }
    transitions_map = get_transitions(ticket)
    response[:transitions] = transitions_map
    pp response
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
    puts "Invalid state. Valid states are"
    pp transitions
  end

  desc 'notify <ticket>', 'notify reviewer of a ticket'
  def notify(ticket, message)
    info = query(ticket)
    reviewer = info[:reviewer]
    body = {
      body: "Hi [~#{reviewer}]. #{message}"
    }
    command = curl_json "-d '#{body.to_json}' '#{ISSUE_BASE_URL}/#{ticket}/comment'"
    `#{command}`
  end

end
