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
    end
  end
end
