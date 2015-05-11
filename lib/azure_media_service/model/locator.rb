module AzureMediaService
  class Locator < Model::Base

    class << self
      def create(policy_id:,asset_id:,type:1)
        post_body = {
          "AccessPolicyId" => policy_id,
          "AssetId" => asset_id,
          "Type" => type,
          "StartTime" => (Time.now - 5*60).gmtime.strftime('%Y-%m-%dT%H:%M:%SZ')
        }
        create_response(service.post("Locators", post_body))
      end
    end

    def delete
      begin 
        res = @request.delete("Locators('#{self.Id}')")
        clear_cache
      rescue => e
        raise MediaServiceError.new(e.message)
      end
      res
    end

  end
end
