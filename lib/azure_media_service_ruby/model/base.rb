require 'ostruct'
module AzureMediaServiceRuby
  module Model
    class Base < OpenStruct

      attr_reader :original_data

      def initialize(hash)
        super
        @original_data = hash
      end
    end
  end
end
