require 'azure_media_service/version'
require 'azure_media_service/errors'
require 'azure_media_service/config'
require 'azure_media_service/request'
require 'azure_media_service/service'
require 'azure_media_service/model'

require 'base64'
require 'openssl'
require 'securerandom'
require 'faraday'
require 'faraday_middleware'
require 'time'
require 'mime/types'
require 'base64'
require 'builder/xmlmarkup'


module AzureMediaService

  @@tasks = {}

  class << self
    attr_accessor :id
    attr_accessor :token_uri
    attr_accessor :media_uri
    attr_accessor :api_version
    attr_accessor :secret

    def configure
      yield self
    end

    def request
      @request ||= Request.new(
        client_id: @id, client_secret: @secret, tokenURI: @token_uri, mediaURI: @media_uri, api_version: @api_version
      )
    end

    def service
      @service ||= Service.new
    end

    def add_encode_task(name, task)
      @@tasks[name] = task
    end

    def encode_tasks
      @@tasks ||= {}
    end

  end
end
