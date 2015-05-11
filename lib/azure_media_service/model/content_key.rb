module AzureMediaService
  class ContentKey < Model::Base

    ContentKeyTypes = {
      CommonEncryption:        0,
      StorageEncryption:       1,
      ConfigurationEncryption: 2,
      EnvelopeEncryption:      4
    }

    class << self
      def create(content_key:, content_key_type: 1,protection_key_type: 0, name: nil )
        id = "nb:kid:UUID:#{SecureRandom.uuid.upcase}"
        # content_key = SecureRandom.random_bytes(16)
        protection_key_id = service.get_protection_key_id(content_key_type)
        protection_key = service.get_protection_key(protection_key_id) # X.509
        x509 = OpenSSL::X509::Certificate.new(Base64.decode64(protection_key))
        public_key = x509.public_key
        encrypted_content_key = Base64.strict_encode64(public_key.public_encrypt(content_key, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING))

        # create checksum
        cipher = OpenSSL::Cipher.new('AES-128-ECB')
        cipher.encrypt
        cipher.key = content_key
        cipher.padding = 0
        encrypt_data = ""
        encrypt_data << cipher.update(protection_key_id[0,16])
        encrypt_data << cipher.final
        check_sum = Base64.strict_encode64(encrypt_data[0,8])

        post_body = {
          "Id"                  => id,
          "ContentKeyType"      => content_key_type,
          "EncryptedContentKey" => encrypted_content_key,
          "ProtectionKeyId"     => protection_key_id,
          "ProtectionKeyType"   => protection_key_type,
          "Checksum"            => check_sum,
          "Name"                => name
        }
        create_response(service.post("ContentKeys", post_body))
      end

      def get(content_key_id=nil)
        service.get('ContentKeys', ContentKey, content_key_id)
      end
    end

    def add_authorization_policy(policy_id)
      res = @request.put("ContentKeys('#{CGI.escape(self.Id)}')", {AuthorizationPolicyId: policy_id})
    end

    # GetKeyDeliveryUrl
    #
    # @params key_delivery_type 1: PlayReady license 2: EnvelopeEncryption
    #
    def get_key_delivery_url(key_delivery_type)
      @request.post("ContentKeys('#{CGI.escape(self.Id)}')/GetKeyDeliveryUrl", {KeyDeliveryType: key_delivery_type})
    end

    def delete
      begin 
        res = @request.delete("ContentKeys('#{self.Id}')")
        clear_cache
      rescue => e
        raise MediaServiceError.new(e.message)
      end
      res
    end
  end
end
