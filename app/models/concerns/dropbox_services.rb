require 'net/http'

module DropboxServices

  def dropbox_get_token(code)
    uri = URI('https://api.dropboxapi.com/oauth2/token')

    params = {
      :code           => code,
      :client_id      => "cea457a609yecr1",
      :client_secret  => "rvx7durrno11xip",
      :redirect_uri   => "http://localhost:3000/api/catalogs/oauth_callback",
      :grant_type     => "authorization_code"
    }

    res = Net::HTTP.post_form(uri, params)

    case res
      when Net::HTTPSuccess
        json_res = JSON.parse(res.body)
        return json_res
      else
        res.value
    end
  end

  def upload(local_file_path, remote_file_path)
    uri = URI("https://content.dropboxapi.com/2/files/upload")
    remote_file_path = "/#{remote_file_path}" #{}"/Apps/Phototank/#{remote_file_path}"

    params = {
      :path         => remote_file_path,
      :mode         => {".tag": "add"},
      :autorename   => false,
    }

    req = Net::HTTP::Post.new(uri.request_uri)
    req['Authorization'] = "Bearer #{self.access_token}"
    req['Dropbox-API-Arg'] = params.to_json
    req['Content-Type'] = "application/octet-stream"
    req.body = File.read(local_file_path)

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') { |http| http.request(req) }

    if res.is_a?(Net::HTTPSuccess)
      return JSON.parse(res.body)
    end

  end
end
