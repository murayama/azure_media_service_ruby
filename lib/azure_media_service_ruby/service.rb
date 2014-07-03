module AzureMediaServiceRuby
  class Service

    def initialize
      @request = AzureMediaServiceRuby.request
    end

    # assets
    def assets(asset_id=nil)
      if asset_id.nil?
        res = @request.get("Assets")
        assets = []
        res["d"]["results"].each do |a|
          assets << Model::Asset.new(a)
        end
      else
        res = @request.get("Assets('#{asset_id}')")
        assets = Model::Asset.new(res["d"])
      end
      assets
    end

    # assets create
    def create_asset(name)
      post_body = {
        "Name" => name
      }
      res = @request.post("Assets", post_body)
      Model::Asset.new(res["d"])
    end

    # access policy create
    def create_access_policy(name:'Policy', duration_minutes:300, permission:2)
      post_body = {
        "Name" => name,
        "DurationInMinutes" => duration_minutes,
        "Permissions" => permission
      }
      res = @request.post("AccessPolicies", post_body)
      Model::AccessPolicy.new(res["d"])
    end

    # locator create
    def create_locator(policy_id:,asset_id:,type:1)
      post_body = {
        "AccessPolicyId" => policy_id,
        "AssetId" => asset_id,
        "Type" => type,
        "StartTime" => (Time.now - 5*60).gmtime.strftime('%Y-%m-%dT%H:%M:%SZ')
      }
      res = @request.post("Locators", post_body)
      Model::Locator.new(res["d"])
    end

    def upload_media(filepath)
      basename = File.basename(filepath, '.*')
      asset_name = "#{basename}-Source-#{Time.now.strftime('%Y%m%d%H%M%S')}"
      asset = create_asset(asset_name)
      asset.upload(filepath)
    end

    def create_encode_job(asset_id, encode_configuration)
      asset = assets(asset_id)
      asset.encode_job(encode_configuration)
    end

    # publish asset
    def publish(asset_id)
      asset = assets(asset_id)
      asset.publish
    end

    def publish_url(asset_id)
      asset = assets(asset_id)
      asset.publish_url
    end

    def media_processor_id_by_name(name)
      res = @request.get('MediaProcessors')
      mp = res["d"]["results"].select {|v| 
        v["Name"] == 'Windows Azure Media Encoder'
      }.sort{|a,b|
        b["Version"].to_i <=> a["Version"].to_i
      }.first
      Model::MediaProcessor.new(mp)
    end

  end
end
