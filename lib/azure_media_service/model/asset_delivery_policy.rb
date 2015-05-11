module AzureMediaService
  class AssetDeliveryPolicy < Model::Base

    Protocol = {
      None:            0x0,
      SmoothStreaming: 0x1,
      Dash:            0x2,
      HLS:             0x4,
      Hds:             0x8,
      All:             0xFFFF
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
          "AssetDeliveryPolicyType" => policy_type,
          "AssetDeliveryConfiguration" => configuration
        }
        res = service.post("AssetDeliveryPolicies", body)
        self.new(res["d"])
      end

      def get(asset_delivery_policy_id=nil)
        service.get("AssetDeliveryPolicies", AssetDeliveryPolicy, asset_delivery_policy_id)
      end
    end

    def delete
      begin 
        res = @request.delete("AssetDeliveryPolicies('#{self.Id}')")
      rescue => e
        raise MediaServiceError.new(e.message)
      end
      res
    end
  end
end
