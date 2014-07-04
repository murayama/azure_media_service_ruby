# AzureMediaServiceRuby

Windows Azure Media Service API Client

## Installation

Add this line to your application's Gemfile:

    gem 'azure_media_service_ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install azure_media_service_ruby

## Usage

```ruby
AzureMediaServiceRuby.configure do |config|
 cofig.id = 'xxxxxxxx' 
 config.secret = 'xxxxxxxxxxxxxxxxxx'
end

ams = new AzureMediaServiceRuby.service

ams.upload_media('path/to/example.mp4')

asset = ams.assets('nb:cid:UUID:xxxxxxxxxxx-xxxxxxxxxxx-xxxxxx-xxxxxxx')
asset.encode_job('H264 Smooth Streaming 720p')
asset.publish
```

## Contributing

1. Fork it ( https://github.com/murayama/azure_media_service_ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
