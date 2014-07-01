module AzureMediaServiceRuby
  class Service

    attr_reader :request

    def initialize(config)
      @request = Request.new(config)
    end

    # assets
    def assets(asset_id=nil)
      if asset_id.nil?
        res = @request.get("Assets")
        assets = []
        p res
        res["d"]["results"].each do |a|
          assets << Model::Assets.new(a)
        end
      else
        res = @request.get("Assets('#{asset_id}')")
        assets = Model::Assets.new(res["d"])
      end
      assets
    end

    # assets create
    def create_asset(name)
      post_body = {
        "Name" => name
      }
      res = @request.post("Assets", post_body)
      res["d"]
    end

    def upload_media(filepath)

      begin
        mime_type = MIME::Types.type_for(filepath)[0].to_s
        basename = File.basename(filepath, '.*')
        filename = File.basename(filepath)
        asset_name = "#{basename}-Source-#{Time.now.strftime('%Y%m%d%H%M%S')}"
        f = Faraday::UploadIO.new(filepath, mime_type)

        # create Assets
        res = create_asset(asset_name)
        # res = @request.post("Assets", %!{"Name":"#{asset_name}"}!)

        asset_id = res["Id"]

        # create policy
        res = @request.post("AccessPolicies", %!{"Name": "UploadPolicy", "DurationInMinutes": "1800", "Permissions":2}!)

        policy_id = res["d"]["Id"]

        # create Locator
        res = @request.post("Locators", %!{"AccessPolicyId":"#{policy_id}", "AssetId":"#{asset_id}", "Type":"1", "StartTime":"#{(Time.now - 5*60).gmtime.strftime('%Y-%m-%dT%H:%M:%SZ')}"}!)

        locator_info = res["d"]

        # upload
        upload_url = File.join(locator_info["BaseUri"], filename)
        upload_url += locator_info["ContentAccessComponent"]

        if f.size > 4194304 # 4MB以上
          # put block and put block list API
          i = 1
          blockids = []
          while buf = f.read(4000000) do
            id = "%05d" % i
            blockid = Base64.strict_encode64("#{id}-#{filename}")
            blockids << blockid
            put_block_url = upload_url + "&comp=block&blockid=#{URI.escape(blockid)}"
            res = @request.put(put_block_url, buf) do |headers|
              headers['x-ms-blob-type'] = 'BlockBlob'
              headers['x-ms-version']   = '2014-02-14' # Storage API Version
              headers['Content-Type']   = 'application/octet-stream'
              headers['Content-Length'] = buf.size.to_s
            end
            i+=1
          end

          put_block_list_url = upload_url + "&comp=blocklist"
          let = ''
          xml = Builder::XmlMarkup.new(:target => let, :indent => 3)
          xml.instruct!
          xml.BlockList {
            blockids.each do |id|
              xml.Latest id
            end
          }

          res = @request.put(put_block_list_url, let) do |headers|
            headers['x-ms-date']      = Time.now.httpdate
            headers['x-ms-version']   = '2014-02-14'
            headers['Content-Type']   = 'text/plain; charset = UTF-8'
            headers['Content-Length'] = let.size.to_s
          end

        else
          # put blob API
          res = @request.put(upload_url, f) do |headers|
            headers['x-ms-blob-type'] = 'BlockBlob'
            headers['x-ms-version']   = '2014-02-14' # Storage API Version
            headers['Content-Type']   = 'application/octet-stream'
            headers['Content-Length'] = f.size.to_s
          end
        end

        # create metadata
        @request.get("CreateFileInfos", {"assetid" => "'#{URI.encode(asset_id)}'"})

      rescue => e
        p e.message
        puts e.backtrace
      end
    end

    def create_job(asset_id, encode_configuration)
      res = media_processor_id_by_name('Windows Azure Media Encoder')
      media_processor_id = res["Id"]

      puts "***** media processor id => #{media_processor_id}"

      asset = assets(asset_id)
      conf_str = encode_configuration.gsub(' ', '_')

      job_names = []
      job_names << asset["Name"]
      job_names << 'EncodeJob'
      job_names << conf_str
      job_name = job_names.join('-')

      output_names = []
      output_names << asset["Name"]
      output_names << conf_str
      output_names << 'Output'
      output_name = output_names.join('-')
      puts job_name

      post_body = {}
      post_body["Name"] = job_name
      post_body["InputMediaAssets"] = [
        {
          "__metadata" => {
            "uri" => asset['__metadata']["uri"]
          }
        }
      ]
      task_body = ''
      xml = Builder::XmlMarkup.new(:target => task_body)
      xml.instruct!
      xml.taskBody {
        xml.inputAsset 'JobInputAsset(0)'
        xml.outputAsset 'JobOutputAsset(0)', :assetName => output_name
      }
      post_body["Tasks"] = [
        {
          "Configuration" => encode_configuration,
          "MediaProcessorId" => media_processor_id,
          "TaskBody" => task_body
        }
      ]
      puts post_body

      res = @request.post('Jobs', post_body)
      # res["d"]
    end

    # publish asset
    def publish(asset_id)
      asset = assets(asset_id)

      res = @request.post("AccessPolicies", %!{"Name": "DownloadPolicy", "DurationInMinutes": "1800", "Permissions":1}!)

      policy_id = res["d"]["Id"]

      res = @request.post("Locators", %!{"AccessPolicyId":"#{policy_id}", "AssetId":"#{asset_id}", "Type":"2", "StartTime":"#{(Time.now - 5*60).gmtime.strftime('%Y-%m-%dT%H:%M:%SZ')}"}!)
    end

    def publish_url(asset_id)
      asset = assets(asset_id)

    end

    def job_state(job_id)
      res = @request.get("Jobs('#{job_id}')/State")
    end

    def media_processor_id_by_name(name)
      res = @request.get('MediaProcessors')
      res["d"]["results"].select {|v| 
        v["Name"] == 'Windows Azure Media Encoder'
      }.sort{|a,b|
        b["Version"].to_i <=> a["Version"].to_i
      }.first
    end

  end
end
