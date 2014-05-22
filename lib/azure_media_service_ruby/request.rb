module AzureMediaServiceRuby
  class Request

    def initialize(config)
      build_config(config) 
    end

    def get(endpoint, params={})

      setToken() if token_expire?

      res = conn(@config[:mediaURI]).get do |req|
        req.url endpoint
        req.headers = @default_headers
        req.headers[:Authorization] = "Bearer #{@access_token}"
        req.params = params
      end

      res.body
    end

    def post(endpoint, body)
      setToken if token_expire?

      res = conn(@config[:mediaURI]).post do |req|
        req.url endpoint
        req.headers = @default_headers
        req.headers[:Authorization] = "Bearer #{@access_token}"
        req.body = body
      end
    end

    def put(url, body)

      _conn = conn(url) do |builder|
        builder.request :multipart
      end

      headers = {
        'Content-Type' => 'application/octet-stream',
        'x-ms-blob-type' => 'BlockBlob',
        'x-ms-version' => '2011-08-18', # Storage API Version
        'Content-Length' => body.size.to_s
      }

      res = _conn.put do |req|
        req.headers = headers
        req.body = body
      end

    end

    private
    def build_config(config)

      @config = config || {}
      # @config[:mediaURI] = "https://media.windows.net/API/"
      @config[:mediaURI] = "https://wamsos1clus001rest-hs.cloudapp.net/api"
      @config[:tokenURI] = "https://wamsprodglobal001acs.accesscontrol.windows.net/v2/OAuth2-13"
      @config[:client_id] ||= ''
      @config[:client_secret] ||= ''

      @default_headers = {
        "Content-Type"          => "application/json;odata=verbose",
        "Accept"                => "application/json;odata=verbose",
        "DataServiceVersion"    => "3.0",
        "MaxDataServiceVersion" => "3.0",
        "x-ms-version"          => "2.5"
      }
    end

    def conn(url)
      conn = Faraday::Connection.new(:url => url, :ssl => {:verify => false}) do |builder|
        builder.request :url_encoded
        builder.response :logger
        builder.use FaradayMiddleware::EncodeJson
        builder.use FaradayMiddleware::ParseJson, :content_type => /\bjson$/
        builder.adapter Faraday.default_adapter
        if block_given?
          yield(builder)
        end
      end
    end

    def setToken
      res = conn(@config[:tokenURI]).post do |req|
        req.body = {
          client_id: @config[:client_id], 
          client_secret: @config[:client_secret],
          grant_type: 'client_credentials',
          scope: 'urn:WindowsAzureMediaServices'
        }
      end

      @access_token = res.body["access_token"]
      @token_expires = Time.now.to_i + res.body["expires_in"].to_i
    end

    def token_expire?
      return true unless @access_token 
      return true if Time.now.to_i >= @token_expires
      return false
    end
  end
end
