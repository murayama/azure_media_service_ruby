require "azure_media_service_ruby/version"
require "faraday"
require "faraday_middleware"

module AzureMediaServiceRuby
  def self.load_path *path
    File.join(File.expand_path('../azure_media_service_ruby', __FILE__), *path)
  end
  # Your code goes here...
  autoload :Request, load_path('request')
  autoload :Service, load_path('service')
end
