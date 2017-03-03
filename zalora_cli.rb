module ZaloraCLI
  def base_url
    "https://zalora.atlassian.net/rest/api/2"
  end

  def curl(host)
    "curl -L -c #{script_dir}/.cookies -b #{script_dir}/.cookies -s #{host}"
  end

  def shop_dir
    '/Users/zalora/shop'
  end

  def docker_dir
    '/Users/zalora/shop-docker'
  end

  def script_dir
    '/Users/zalora/zalora_cli'
  end

  def get_transitions(ticket)
    command = curl("'#{base_url}/issue/#{ticket}/transitions'")
    JSON.parse(`#{command}`)['transitions']
  end


end
