require 'ostruct'
module AzureMediaServiceRuby
  module Model
    class Base < OpenStruct

      attr_reader :original_data

      def initialize(hash)
        super
        @original_data = hash
        @request = AzureMediaServiceRuby.request
        @service = AzureMediaServiceRuby.service
      end
    end
  end
end
