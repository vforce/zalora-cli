module ZaloraCLI
  def base_url
    "https://zalora.atlassian.net/rest/api/2"
  end

  def curl(host)
    "curl -L -c #{script_dir}/.cookies -b #{script_dir}/.cookies -s #{host}"
  end

  def curl_json(host)
    curl "-H 'Content-Type: application/json' #{host}"
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


end
