#!/usr/bin/env ruby
require 'azure_media_service'

p :upload_content

# initialize
AzureMediaService.configure do |config|
  # Media Service Account Name
  config.id = 'thisismytest'
  # Media Service Access Key
  config.secret = 'fW5f/kjOY4v5eIVCUZebInIJvbmS49M1+1rlzPLOJsg='
end

# Test files located at
# => http://download.wavetlan.com/SVV/Media/HTTP/http-mp4.htm

# Download test file in sample directory
# wget http://download.wavetlan.com/SVV/Media/HTTP/H264/Talkinghead_Media/H264_test3_Talkingheadclipped_mp4_480x360.mp4

# If missing wget, brew install wget.
# To install brew: http://brew.sh/

media_file_name = 'H264_test3_Talkingheadclipped_mp4_480x360.mp4'

# Upload file
ams = AzureMediaService.service
asset = ams.upload_media(media_file_name)

p asset

# Verify upload: https://manage.windowsazure.com/
p :done
