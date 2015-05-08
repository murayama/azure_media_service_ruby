module AzureMediaService
  class ContentKeyAuthorizationPolicyOption < Model::Base

    KeyDeliveryTypes = {
      None:             0,
      PlayReadyLicense: 1,
      BaselineHttp:     2
    }

    KeyRestrictionTypes = {
      Open:            0,
      TokenRestricted: 1,
      IPRestricted:    2
    }

    class << self
      def create(name:, key_delivery_type:, key_delivery_configuration:, restrictions:)
        post_body = {
          "Name" => name,
          "KeyDeliveryType" => key_delivery_type,
          "KeyDeliveryConfiguration" => key_delivery_configuration,
          "Restrictions" => restrictions
        }
        res = service.post("ContentKeyAuthorizationPolicyOptions", post_body)
      end
    end

  end
end

