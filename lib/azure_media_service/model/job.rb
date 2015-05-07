module AzureMediaService
  module Model
    class Job < Base

      class << self
        def create(asset_id, encode_configuration)
          asset = Model::Asset.get(asset_id)
          asset.encode_job(encode_configuration)
        end

        def get(job_id=nil)
          service.get('Jobs', Model::Job, job_id)
        end
      end

      def output_assets
        @output_assets ||= []
        if @output_assets.empty?
          _uri = URI.parse(self.OutputMediaAssets["__deferred"]["uri"])
          url = _uri.path.gsub('/api/','')
          res = @request.get(url)
          res["d"]["results"].each do |v|
            @output_assets << Model::Asset.new(v)
          end
        end
        @output_assets
      end

      def input_assets
        @input_assets ||= []
        if @input_assets.empty?
          _uri = URI.parse(self.InputMediaAssets["__deferred"]["uri"])
          url = _uri.path.gsub('/api/','')
          res = @request.get(url)
          res["d"]["results"].each do |v|
            @input_assets << Model::Asset.new(v)
          end
        end
        @input_assets
      end
    end
  end
end
