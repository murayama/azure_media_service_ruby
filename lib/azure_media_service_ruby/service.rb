module AzureMediaServiceRuby
  class Service

    def initialize(config)
      @request = Request.new(config)
    end

    def assets
      @request.get('Assets')
    end

    def create_asset()
      @request.post()
    end

    def list_asset_files
      @request.get('Files')
    end

    def download_url(asset_id)

    end

    def upload_media(filepath)

      begin
        mime_type = MIME::Types.type_for(filepath)[0].to_s
        basename = File.basename(filepath, '.*')
        filename = File.basename(filepath)
        asset_name = "#{basename}-Source-#{Time.now.strftime('%Y%m%d%H%M%S')}"
        f = Faraday::UploadIO.new(filepath, mime_type)

        # create Assets
        res = @request.post("Assets", %!{"Name":"#{asset_name}"}!)

        asset_id = res.body["d"]["Id"]

        # create policy
        res = @request.post("AccessPolicies", %!{"Name": "UploadPolicy", "DurationInMinutes": "300", "Permissions":2}!)

        policy_id = res.body["d"]["Id"]

        # create Locator
        res = @request.post("Locators", %!{"AccessPolicyId":"#{policy_id}", "AssetId":"#{asset_id}", "Type":"1"}!)

        # upload
        upload_url = File.join(res.body["d"]["BaseUri"], filename)
        upload_url += res.body["d"]["ContentAccessComponent"]

        res = @request.put(upload_url, f)

        # create metadata
        @request.get("CreateFileInfos", {"assetid" => "'#{URI.encode(asset_id)}'"})

      rescue => e
        p e.message
      end
    end
  end
end
