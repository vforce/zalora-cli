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
    ENV['home_dir'] + '/shop'
  end

  def docker_dir
    ENV['home_dir'] + '/shop-docker'
  end

  def script_dir
    ENV['home_dir'] + '/zalora-cli'
  end
end
