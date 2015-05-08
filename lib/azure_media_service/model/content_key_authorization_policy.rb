module AzureMediaService
  class ContentKeyAuthorizationPolicy < Model::Base

    class << self
      def create(name)
        res = service.post("ContentKeyAuthorizationPolicies", {Name: name})
        self.new(res["d"])
      end

      def get(content_key_authorization_policy_id=nil)
        service.get("ContentKeyAuthorizationPolicies", ContentKeyAuthorizationPolicy, content_key_authorization_policy_id)
      end
    end

    def option_link(options_uri)
      @request.post("ContentKeyAuthorizationPolicies('#{CGI.escape(self.id)}')/$links/Options", {uri: options_uri})
    end
  end
end
