require 'azure_media_service/version'
require 'azure_media_service/errors'
require 'azure_media_service/config'
require 'azure_media_service/request'
require 'azure_media_service/service'
require 'azure_media_service/model'

require 'faraday'
require 'faraday_middleware'
require 'time'
require 'mime/types'
require 'base64'
require 'builder/xmlmarkup'

autoload :Asset, 'model/asset'

module AzureMediaService

  @@tasks = {}

  class << self

    def configure
      yield self
    end

    def request
      @@request ||= Request.new(client_id:@@id, client_secret:@@secret)
    end

    def service
      @@service ||= Service.new
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

    def add_encode_task(name, task)
      @@tasks[name] = task
    end

    def encode_tasks
      @@tasks ||= {}
    end

  end
end
