module AzureMediaService
  class AccessPolicy < Model::Base

    class << self
      def create(name:'Policy', duration_minutes:300, permission:2)
        post_body = {
          "Name" => name,
          "DurationInMinutes" => duration_minutes,
          "Permissions" => permission
        }
        res = service.post("AccessPolicies", post_body)
        self.new(res["d"])
      end
    end

  end
end
