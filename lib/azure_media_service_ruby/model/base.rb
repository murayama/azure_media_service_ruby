module AzureMediaServiceRuby
  module Model
    class Base

      def initialize(hash)
        @__original_data = hash
      end

      def method_missing(key, val)

      end
    end
  end
end
