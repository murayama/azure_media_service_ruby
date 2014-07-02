require 'azure_media_service_ruby/version'
require 'azure_media_service_ruby/request'
require 'azure_media_service_ruby/service'
require 'azure_media_service_ruby/model'

require 'faraday'
require 'faraday_middleware'
require 'time'
require 'mime/types'
require 'net/http'
require 'httpclient'
require 'base64'
require 'builder/xmlmarkup'

module AzureMediaServiceRuby

  @@secret
  @@request

  class << self

    def configure
      yield self
    end

    def request
      @@request ||= Request.new(client_id:@@id, client_secret:@@secret)
    end

    def id=(v)
      @@id = v
    end

    def id
      @@id
    end

    def secret=(v)
      @@secret = v
    end

    def secret
      @@secret
    end
  end

end
