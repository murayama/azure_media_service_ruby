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
  # def self.load_path *path
  #   File.join(File.expand_path('../azure_media_service_ruby', __FILE__), *path)
  # end
  # autoload :Request, load_path('request')
  # autoload :Service, load_path('service')
end
