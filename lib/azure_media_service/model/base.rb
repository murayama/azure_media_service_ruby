require 'ostruct'
module AzureMediaService
  module Model
    class Base < OpenStruct

      attr_reader :original_data

      def initialize(hash)
        super
        @original_data = hash
        @request = AzureMediaService.request
        @service = AzureMediaService.service
      end

      class << self

        def service
          AzureMediaService.service
        end

        def create_response(res)
          if res["d"]
            self.new(res["d"])
          else
            raise MediaServiceError.new(res["error"]["message"]["value"])
        end
        end

      end
    end
  end
end
