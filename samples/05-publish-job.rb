#!/usr/bin/env ruby
require 'azure_media_service'

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
asset = AzureMediaService::Asset.create('dynamic_packaging')
asset.upload(media_file_name)
job = asset.encode_job('H264 Broadband 1080p')
@request = AzureMediaService.request
while true
  res = @request.get('Jobs')
  state = res['d']['results'].find{|entry| entry['Id'] == job['Id'] }['State']
  p [Time.now, state]
  break if state == 3
end

# Create OnDemand Locator
p job.output_assets.first.publish
manifest = job.output_assets.first.publish_url

# Print Smooth Publish URL
smooth_url = manifest

# Print HLS Publish URL
hls_url = manifest + "(format=m3u8-aapl)"

# Print DASH Publish URL
dash_url = manifest + "(format=mpd-time-csf)"

puts "Smooth URL: #{smooth_url}"
puts "HLS URL: #{hls_url}"
puts "DASH URL: #{dash_url}"
