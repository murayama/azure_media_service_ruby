module AzureMediaServiceRuby
  class Service

    UPLOAD_LIMIT_SIZE = 4194304 # 4MB
    READ_BUFFER_SIZE       = 4000000

    attr_reader :request

    def initialize(config)
      @request = Request.new(config)
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

      begin
        mime_type = MIME::Types.type_for(filepath)[0].to_s
        basename = File.basename(filepath, '.*')
        filename = File.basename(filepath)
        asset_name = "#{basename}-Source-#{Time.now.strftime('%Y%m%d%H%M%S')}"
        f = Faraday::UploadIO.new(filepath, mime_type)

        # create Assets
        asset = create_asset(asset_name)

        # create policy
        policy = create_access_policy(name:"UploadPolicy", duration_minutes:1800, permission:2)

        # create Locator
        locator = create_locator(policy_id:policy.Id, asset_id:asset.Id, type:1)

        # upload
        upload_url = File.join(locator.BaseUri, filename)
        upload_url += locator.ContentAccessComponent

        if f.size > UPLOAD_LIMIT_SIZE
          # put block and put block list API
          i = 1
          blockids = []
          while buf = f.read(READ_BUFFER_SIZE) do
            id = "%05d" % i # サイズを同じにしなければいけないので、5桁にする
            blockid = Base64.strict_encode64("#{id}-#{filename}")
            blockids << blockid
            put_block_url = upload_url + "&comp=block&blockid=#{URI.escape(blockid)}"
            res = put_blob(url:put_block_url, blob:buf)
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
          res = put_blob(url:upload_url, blob:f)
        end

        # create metadata
        @request.get("CreateFileInfos", {"assetid" => "'#{URI.encode(asset.Id)}'"})

      rescue => e
        p e.message
        puts e.backtrace
      end
    end

    def create_job(asset_id, encode_configuration)
      media_processor = media_processor_id_by_name('Windows Azure Media Encoder')

      puts "***** media processor id => #{media_processor.Id}"

      asset = assets(asset_id)
      conf_str = encode_configuration.gsub(' ', '_')

      job_name, output_name = job_and_output_name(asset_name:asset.Name, conf:conf_str)

      post_body = {}
      post_body["Name"] = job_name
      post_body["InputMediaAssets"] = [
        {
          "__metadata" => {
            "uri" => asset.__metadata["uri"]
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
          "MediaProcessorId" => media_processor.Id,
          "TaskBody" => task_body
        }
      ]
      puts post_body

      res = @request.post('Jobs', post_body)
      Model::Job.new(res["d"])
    end

    # publish asset
    def publish(asset_id)
      asset = assets(asset_id)

      policy = create_access_policy(name:"DownloadPolicy", duration_minutes:1800, permission:1)

      locator = create_locator(policy_id:policy.Id, asset_id:asset.Id, type:2)
    end

    def publish_url(asset_id)
      asset = assets(asset_id)
    end

    def job_state(job_id)
      res = @request.get("Jobs('#{job_id}')/State")
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

    private
    def put_blob(url:, blob:)
      res = @request.put(url, blob) do |headers|
        headers['x-ms-blob-type'] = 'BlockBlob'
        headers['x-ms-version']   = '2014-02-14' # Storage API Version
        headers['Content-Type']   = 'application/octet-stream'
        headers['Content-Length'] = blob.size.to_s
      end
    end

    def job_and_output_name(asset_name:, conf:)
      job_names = []
      job_names << asset_name
      job_names << 'EncodeJob'
      job_names << conf
      job_name = job_names.join('-')

      output_names = []
      output_names << asset_name
      output_names << conf
      output_names << 'Output'
      output_name = output_names.join('-')

      [job_name, output_name]
    end

  end
end
