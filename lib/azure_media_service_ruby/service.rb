module AzureMediaServiceRuby
  class Service

    def initialize(config)
      @request = Request.new(config)
    end

    def assets
      @request.get('Assets')
    end
  end
end
