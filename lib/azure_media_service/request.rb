module AzureMediaService
  class Request

    def initialize(config)
      build_config(config) 
    end

    def get(endpoint, params={})

      setToken() if token_expire?

      res = conn(@config[:mediaURI]).get do |req|
        req.url URI.escape(endpoint, '():')
        req.headers = @default_headers
        req.headers[:Authorization] = "Bearer #{@access_token}"
        req.params = params
      end

      if res.status == 301
        @config[:mediaURI] = res.headers['location']
        get(endpoint, params)
      else
        if res.headers[:error]
          raise MediaServiceError.new("#{res.headers[:error]}: #{res.headers[:error_description]}")
        end
        res.body
      end
    end

    def post(endpoint, body)
      setToken if token_expire?

      res = conn(@config[:mediaURI]).post do |req|
        req.url endpoint
        req.headers = @default_headers
        req.headers[:Authorization] = "Bearer #{@access_token}"
        req.body = body
      end

      if res.status == 301
        @config[:mediaURI] = res.headers['location']
        post(endpoint, body)
      else
        if res.headers[:error]
          raise MediaServiceError.new("#{res.headers[:error]}: #{res.headers[:error_description]}")
        end
        res.body
      end
    end

    def put(endpoint, body)
      setToken if token_expire?

      res = conn(@config[:mediaURI]).put do |req|
        req.url endpoint
        req.headers = @default_headers
        req.headers[:Authorization] = "Bearer #{@access_token}"
        req.body = body
      end

      if res.status == 301
        @config[:mediaURI] = res.headers['location']
        post(endpoint, body)
      else
        if res.headers[:error]
          raise MediaServiceError.new("#{res.headers[:error]}: #{res.headers[:error_description]}")
        end
        res.body
      end
    end

    def put_row(url, body)

      _conn = conn(url) do |builder|
        builder.request :multipart
      end

      headers = {}

      if block_given?
        yield(headers)
      end

      res = _conn.put do |req|
        req.headers = headers
        req.body = body
      end
      if res.status == 301
        @config[:mediaURI] = res.headers['location']
        put(url, body)
      else
        if res.headers[:error]
          raise MediaServiceError.new("#{res.headers[:error]}: #{res.headers[:error_description]}")
        end
        res.body
      end
    end

    def delete(endpoint, params={})

      setToken() if token_expire?

      res = conn(@config[:mediaURI]).delete do |req|
        req.url URI.escape(endpoint, '():')
        req.headers = @default_headers
        req.headers[:Authorization] = "Bearer #{@access_token}"
        req.params = params
      end

      if res.status == 301
        @config[:mediaURI] = res.headers['location']
        delete(endpoint, params)
      else
        if res.headers[:error]
          raise MediaServiceError.new("#{res.headers[:error]}: #{res.headers[:error_description]}")
        end
        res.body
      end
    end

    private
    def build_config(config)

      @config = config || {}
      # @config[:mediaURI] = "https://media.windows.net/API/"
      @config[:mediaURI] || raise(MediaServiceError.new('Media URI missing, please specify in config'))
      @config[:tokenURI] || raise(MediaServiceError.new('Token URI missing, please specify in config'))
      @config[:client_id] || raise(MediaServiceError.new('Client ID missing, please specify in config'))
      @config[:client_secret] || raise(MediaServiceError.new('Client secret missing, please specify in config'))

      @default_headers = {
        "Content-Type"          => "application/json;odata=verbose",
        "Accept"                => "application/json;odata=verbose",
        "DataServiceVersion"    => "3.0",
        "MaxDataServiceVersion" => "3.0",
        "x-ms-version"          => @config[:api_version] || Config::API_VERSION
      }
    end

    def conn(url)
      conn = Faraday::Connection.new(:url => url, :ssl => {:verify => false}) do |builder|
        builder.request :url_encoded
        # builder.response :logger
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
          resource: 'https://rest.media.azure.net'
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
