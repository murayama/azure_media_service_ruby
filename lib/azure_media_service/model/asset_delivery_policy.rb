module AzureMediaService
  class AssetDeliveryPolicy < Model::Base

    Protocol = {
      None:            0,
      SmoothStreaming: 1,
      Dash:            2,
      HLS:             3,
      Hds:             4,
      All:             5
    }

    PolicyType = {
      None:                      0,
      Blocked:                   1,
      NoDynamicEncryption:       2,
      DynamicEnvelopeEncryption: 3,
      DynamicCommonEncryption:   4
    }

    ConfigurationKey = {
      None:                           0,
      EnvelopeKeyAcquisitionUrl:      1,
      EnvelopeBaseKeyAcquisitionUrl:  2,
      EnvelopeEncryptionIVAsBase64:   3,
      PlayReadyLicenseAcquisitionUrl: 4,
      PlayReadyCustomAttributes:      5,
      EnvelopeEncryptionIV:           6
    }


    class << self
      def create(name:, protocol:, policy_type:, configuration:)
        body = {
          "Name" => name,
          "AssetDeliveryProtocol" => protocol,
          "AssetDelivertPolicyType" => protocol,
          "AssetDeliveryConfiguration": configuration
        }
        res = service.post("AssetDeliveryPolicies", body)
        self.new(res["d"])
      end

      def get(asset_delivery_policy_id=nil)
        service.get("AssetDeliveryPolicies", AssetDeliveryPolicy, asset_delivery_policy_id)
      end
    end
  end
end
