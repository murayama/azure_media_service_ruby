module AzureMediaService
  class Asset < Model::Base

    class << self

      def create(name)
        post_body = {
          "Name" => name
        }
        res = service.post("Assets", post_body)
        self.new(res["d"])
      end

      def get(asset_id=nil)
        service.get('Assets', Asset, asset_id)
      end
    end

    def locators
      @locators ||= []
      if @locators.empty?
        _uri = URI.parse(self.Locators["__deferred"]["uri"])
        url = _uri.path.gsub('/api/','')
        res = @request.get(url)
        res["d"]["results"].each do |v|
          @locators << Locator.new(v)
        end
      end
      @locators
    end

    def files
      @files ||= []
      if @files.empty?
        _uri = URI.parse(self.Files["__deferred"]["uri"])
        url = _uri.path.gsub('/api/','')
        res = @request.get(url)
        res["d"]["results"].each do |v|
          @files << AssetFile.new(v)
        end
      end
      @files
    end

    def upload(filepath)
      begin
        mime_type = MIME::Types.type_for(filepath)[0].to_s
        basename = File.basename(filepath, '.*')
        filename = File.basename(filepath)
        f = Faraday::UploadIO.new(filepath, mime_type)

        # create policy
        policy = AccessPolicy.create(name:"UploadPolicy", duration_minutes:1800, permission:2)

        # create Locator
        locator = Locator.create(policy_id:policy.Id, asset_id:self.Id, type:1)

        # upload
        upload_url = File.join(locator.BaseUri, filename)
        upload_url += locator.ContentAccessComponent

        if f.size > Config::UPLOAD_LIMIT_SIZE
          # put block and put block list API
          i = 1
          blockids = []
          while buf = f.read(Config::READ_BUFFER_SIZE) do
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
        @request.get("CreateFileInfos", {"assetid" => "'#{URI.encode(self.Id)}'"})

        clear_cache
      rescue => e
        raise MediaServiceError.new(e.message)
      end
      self
    end


    def encode_job(encode_configuration) 
      media_processor = @service.media_processor_id_by_name('Windows Azure Media Encoder')

      conf_str = encode_configuration.gsub(' ', '_')

      if AzureMediaService.encode_tasks.has_key?(encode_configuration)
        encode_configuration = AzureMediaService.encode_tasks[encode_configuration]
      end

      job_name, output_name = job_and_output_name(asset_name:self.Name, conf:conf_str)

      post_body = {}
      post_body["Name"] = job_name
      post_body["InputMediaAssets"] = [
        {
          "__metadata" => {
            "uri" => self.__metadata["uri"]
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

      res = @request.post('Jobs', post_body)
      Job.new(res["d"])
    end


    def publish(expire_minutes: 43200)
      locator = locators.select {|l| l.Type == 2}.first
      unless locator
        policy = AccessPolicy.create(name:"PublishPolicy", duration_minutes: expire_minutes, permission:1)
        locator = Locator.create(policy_id: policy.Id, asset_id: self.Id, type: 2)
      end
      locator
    end

    def publish_url
      primary_file = files.select {|f| f.IsPrimary == true}.first
      locator = locators.select {|l| l.Type == 2 }.first
      if primary_file && locator
        File.join(locator.Path, primary_file.Name, 'Manifest')
      else
        nil
      end
    end

    def delete
      begin 
        res = @request.delete("Assets('#{self.Id}')")
        clear_cache
      rescue => e
        raise MediaServiceError.new(e.message)
      end
      res
    end

    def content_key_link(content_key_uri)
      @request.post("Assets('#{self.Id}')/$links/ContentKeys", {uri: content_key_uri})
    end

    private

    def clear_cache
      @locators = nil
      @files = nil
      self
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

    def put_blob(url:, blob:)
      res = @request.put(url, blob) do |headers|
        headers['x-ms-blob-type'] = 'BlockBlob'
        headers['x-ms-version']   = '2014-02-14' # Storage API Version
        headers['Content-Type']   = 'application/octet-stream'
        headers['Content-Length'] = blob.size.to_s
      end
    end
  end

end
