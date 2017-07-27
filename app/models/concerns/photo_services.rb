require 'net/http'

module PhotoServices

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
      when Net::HTTPSuccess, Net::HTTPRedirection
        json_res = JSON.parse(res.body)
        return json_res
      else
        res.value
    end
  end

  def flickr_get_request_token
    uri = URI('https://www.flickr.com/services/oauth/request_token')
    http_verb = "GET"

    consumer_secret = "a52641f4fc5064f017257f7b312f3445"
    token_secret = "eaf9c9a478fa37bd"
    signature_key = "#{consumer_secret}&#{token_secret}"


    params = {
      :oauth_nonce => get_nonce,
      :oauth_timestamp => Time.now.utc.to_i,
      :oauth_consumer_key => "a52641f4fc5064f017257f7b312f3445",
      :oauth_signature_method => "HMAC-SHA1",
      :oauth_version => "1.0",
      :oauth_callback => "http://localhost:3000/api/catalogs/oauth_callback"
    }

    uris = 'https://www.flickr.com/services/oauth/request_token'
    base_string = params.sort.map {| k,v | "#{k}=#{v}&" }.join
    base_string = base_string.chomp('&')
    base_string = CGI.escape(base_string)
    base_string = "#{http_verb}&#{CGI.escape(uris)}&#{base_string}"


    params[:oauth_signature] = get_signature(signature_key, base_string)
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

  end

  def get_signature(secret, data)
    require 'base64'
    require 'cgi'
    require 'openssl'
    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), secret.encode("ASCII"), data.encode("ASCII"))
    return hmac
  end

  def get_nonce
    10.times.map{rand(10)}.join.to_i
  end

end
