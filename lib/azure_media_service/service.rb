module AzureMediaService
  class Service

    def initialize
      @request = AzureMediaService.request
    end

    # assets
    # def assets(asset_id=nil)
    #   get('Assets', Model::Asset, asset_id)
    # end

    # assets create
    # def create_asset(name)
    #   post_body = {
    #     "Name" => name
    #   }
    #   res = @request.post("Assets", post_body)
    #   Model::Asset.new(res["d"])
    # end

    # access policy create
    # def create_access_policy(name:'Policy', duration_minutes:300, permission:2)
    #   post_body = {
    #     "Name" => name,
    #     "DurationInMinutes" => duration_minutes,
    #     "Permissions" => permission
    #   }
    #   res = @request.post("AccessPolicies", post_body)
    #   Model::AccessPolicy.new(res["d"])
    # end

    # locator create
    # def create_locator(policy_id:,asset_id:,type:1)
    #   post_body = {
    #     "AccessPolicyId" => policy_id,
    #     "AssetId" => asset_id,
    #     "Type" => type,
    #     "StartTime" => (Time.now - 5*60).gmtime.strftime('%Y-%m-%dT%H:%M:%SZ')
    #   }
    #   res = @request.post("Locators", post_body)
    #   Model::Locator.new(res["d"])
    # end

    def upload_media(filepath)
      basename = File.basename(filepath, '.*')
      asset_name = "#{basename}-Source-#{Time.now.strftime('%Y%m%d%H%M%S')}"
      asset = Asset.create(asset_name)
      asset.upload(filepath)
    end

    # def create_encode_job(asset_id, encode_configuration)
    #   asset = assets(asset_id)
    #   asset.encode_job(encode_configuration)
    # end
    #
    # def jobs(job_id=nil)
    #   get('Jobs', Model::Job, job_id)
    # end


    # publish asset
    # def publish(asset_id, expire_minutes=nil)
    #   asset = Model::Asset.get(asset_id)
    #   asset.publish(expire_minutes)
    # end
    #
    # def publish_url(asset_id)
    #   asset = Model::Asset.get(asset_id)
    #   asset.publish_url
    # end

    def media_processor_id_by_name(name)
      res = @request.get('MediaProcessors')
      mp = res["d"]["results"].select {|v| 
        v["Name"] == 'Windows Azure Media Encoder'
      }.sort{|a,b|
        b["Version"].to_i <=> a["Version"].to_i
      }.first
      MediaProcessor.new(mp)
    end

    def get_protection_key_id(content_key_type)
      res = @request.get("GetProtectionKeyId", contentKeyType: content_key_type)
      if res["d"]
        res["d"]["GetProtectionKeyId"]
      else
        raise MediaServiceError.new(res["error"]["message"]["value"])
      end
    end

    def get_protection_key(protection_key_id)
      res = @request.get("GetProtectionKey", ProtectionKeyId: "'#{protection_key_id}'")
      if res["d"]
        res["d"]["GetProtectionKey"]
      else
        raise MediaServiceError.new(res["error"]["message"]["value"])
      end
    end

    def get(method, klass, id=nil)
      if id.nil?
        res = @request.get(method)
        results = []
        res["d"]["results"].each do |a|
          results << klass.new(a)
        end
      else
        res = @request.get("#{method}('#{id}')")
        results = klass.new(res["d"])
      end
      results
    end

    def post(method, body)
      @request.post(method, body)
    end

  end
end
