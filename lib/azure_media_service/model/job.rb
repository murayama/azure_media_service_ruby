module AzureMediaService
  module Model
    class Job < Base

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
