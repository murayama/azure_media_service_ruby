module AzureMediaServiceRuby
  class Service

    def initialize(config)
      @request = Request.new(config)
    end
  end
end
