module AzureMediaService
  class ContentKey < Model::Base

    class << self
      def create(id:, content_key_type:, encrypted_content_key:, protection_key_id:, protection_key_type:, check_sum:)
        post_body = {
          "Id" => id,
          "ContentKeyType" => content_key_type,
          "EncryptedContentKey" => encrypted_content_key,
          "ProtectionKeyId" => protection_key_id,
          "ProtectionKeyType" => protection_key_type,
          "Checksum" => check_sum
        }
        res = service.post("ContentKeys", post_body)
        self.new(res["d"])
      end

      def get(content_key_id=nil)
        service.get('ContentKeys', ContentKey, content_key_id)
      end
    end
  end
end
