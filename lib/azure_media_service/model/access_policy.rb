module AzureMediaService
  class AccessPolicy < Model::Base

    class << self
      def create(name:'Policy', duration_minutes:300, permission:2)
        post_body = {
          "Name" => name,
          "DurationInMinutes" => duration_minutes,
          "Permissions" => permission
        }
        create_response(service.post("AccessPolicies", post_body))
      end
    end

    def delete
      begin 
        res = @request.delete("AccessPolicies('#{self.Id}')")
      rescue => e
        raise MediaServiceError.new(e.message)
      end
      res
    end

  end
end
