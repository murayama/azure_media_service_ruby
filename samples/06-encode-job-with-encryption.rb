#!/usr/bin/env ruby
require 'azure_media_service'

p :upload_content

# initialize
AzureMediaService.configure do |config|
  # Media Service Account Name
  config.id = 'wiprolimited'
  # Media Service Access Key
  config.secret = 'robpEX8IQjir0wZEcFGo+Xp+H2GhazBTa9te3yM8+RQ='
end

# Test files located at
# => http://download.wavetlan.com/SVV/Media/HTTP/http-mp4.htm

# Download test file in sample directory
# wget http://download.wavetlan.com/SVV/Media/HTTP/H264/Talkinghead_Media/H264_test3_Talkingheadclipped_mp4_480x360.mp4

# If missing wget, brew install wget.
# To install brew: http://brew.sh/

media_file_name = 'H264_test3_Talkingheadclipped_mp4_480x360.mp4'

# Upload file
asset = AzureMediaService::Asset.create('encrypted.asset', AzureMediaService::Asset::Options[:StorageEncrypted])
asset.upload(media_file_name)

p :upload_successful
p :encode_asset

# Encode asset in 720 H264
p asset.encode_job('H264 Broadband 1080p')
# p asset.encode_job('H264 Smooth Streaming 720p')

# Verify upload: https://manage.windowsazure.com/
p :done
