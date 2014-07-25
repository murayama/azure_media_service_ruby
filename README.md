# AzureMediaServiceRuby

Windows Azure Media Service API Client

## Installation

Add this line to your application's Gemfile:

    gem 'azure_media_service'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install azure_media_service

## Usage

```ruby

# initialize
AzureMediaService.configure do |config|
 cofig.id = 'xxxxxxxx' 
 config.secret = 'xxxxxxxxxxxxxxxxxx'
end

# service instance
ams = AzureMediaService.service

# upload file
ams.upload_media('path/to/example.mp4')

# encode job and publish
asset = ams.assets('nb:cid:UUID:xxxxxxxxxxx-xxxxxxxxxxx-xxxxxx-xxxxxxx')
asset.encode_job('H264 Smooth Streaming 720p')
asset.publish

# or
ams.create_encode_job('nb:cid:UUID:xxxxxxxxxxx-xxxxxxxxxxx-xxxxxx-xxxxxxx', 'H264 Smooth Streaming 720p')
ams.publish('nb:cid:UUID:xxxxxxxxxxx-xxxxxxxxxxx-xxxxxx-xxxxxxx')

```

### Custom Encode Task

```ruby
AzureMediaService.configure do |config|
  config.add_encode_task('Custom Encode Task', File.read('path/to/custome_task.xml'))
end

ams = AzureMediaService.service
asset = ams.assets('nb:cid:UUID:xxxxxxxxxxx-xxxxxxxxxxx-xxxxxx-xxxxxxx')
asset.encode_job('Custom Encode Task')
```

## Contributing

1. Fork it ( https://github.com/murayama/azure_media_service_ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
