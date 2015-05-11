module AzureMediaService
  class ContentKeyAuthorizationPolicy < Model::Base

    class << self
      def create(name)
        create_response(service.post("ContentKeyAuthorizationPolicies", {Name: name}))
      end

      def get(content_key_authorization_policy_id=nil)
        service.get("ContentKeyAuthorizationPolicies", ContentKeyAuthorizationPolicy, content_key_authorization_policy_id)
      end
    end

    def option_link(options)
      @request.post("ContentKeyAuthorizationPolicies('#{CGI.escape(self.Id)}')/$links/Options", {uri: options.__metadata['uri']})
    end

    def delete
      begin 
        res = @request.delete("ContentKeyAuthorizationPolicies('#{self.Id}')")
      rescue => e
        raise MediaServiceError.new(e.message)
      end
      res
    end
  end
end
