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
 config.id = 'xxxxxxxx'
 config.secret = 'xxxxxxxxxxxxxxxxxx'
end

# upload file
ams = AzureMediaService.service
asset = ams.upload_media('path/to/example.mp4')

# or

asset = AzureMediaService::Asset.create(asset_name)
asset.upload('path/to/example.mp4')

# encode job
asset = AzureMediaService::Asset.get('nb:cid:UUID:xxxxxxxxxxx-xxxxxxxxxxx-xxxxxx-xxxxxxx')
job = asset.encode_job('H264 Smooth Streaming 720p')

# or
job = AzureMediaService::Job.create('nb:cid:UUID:xxxxxxxxxxx-xxxxxxxxxxx-xxxxxx-xxxxxxx', 'H264 Smooth Streaming 720p')

# publish asset
asset = AzureMediaService::Asset.get('nb:cid:UUID:xxxxxxxxxxx-xxxxxxxxxxx-xxxxxx-xxxxxxx')
asset.publish(expire_minutes: 43200)

```

### Custom Encode Task

```ruby
AzureMediaService.configure do |config|
  config.add_encode_task('Custom Encode Task', File.read('path/to/custome_task.xml'))
end

asset = AzureMediaService::Asset.get('nb:cid:UUID:xxxxxxxxxxx-xxxxxxxxxxx-xxxxxx-xxxxxxx')
asset.encode_job('Custom Encode Task')
```

### AES Protection

```ruby
asset = AzureMediaService::Asset.get(asset_id)

key = ScureRandom::random_bytes(16)

content_key = AzureMediaService::ContentKey.create({
  content_key: key,
  content_key_type: AzureMediaService::ContentKey::ContentKeyTypes[:EnvelopeEncryption],
  name: 'content-key-name'
})
asset.content_key_link(content_key)


content_key_policies = AzureMediaService::ContentKeyAuthorizationPolicy.get()
content_key_policy = content_key_policies.fin { |p| p.name == 'your policy name' }
unless content_key_policy
  content_key_policy = AzureMediaService::ContentKeyAuthorizationPolicy.create('your policy name')
  policy_options = AzureMediaService::ContentKeyAuthorizationPolicyOption.create({
    name: 'policy option',
    key_delivery_type: AzureMediaService::ContentKeyAuthorizationPolicyOption::KeyDeliveryTypes[:BaselineHttp],
    key_delivery_configuration: nil,
    restrictions: [
      {
        "Name" => "HLS Authorization Policy",
        "KeyRestrictionType" => AzureMediaService::ContentKeyAuthorizationPolicyOption::KeyRestrictionTypes[:Open]
      }
    ]
  })
  content_key_policy.option_link(policy_options)
end

content_key.add_authorization_policy(content_key_policy.Id)

protocols = AzureMediaService::AssetDeliveryPolicy::Protocol
# Your need to register the key to your key delivery server
kid = content_key.Id.split(':').last
key_delivery_url = "your key delivery server url"
delivery_policy = AzureMediaService::AssetDeliveryPolicy.create({
  name: 'your delivery policy name',
  protocol: protocols[:HLS] | protocols[:SmoothStreaming] | protocols[:Dash],
  policy_type: AzureMediaService::AssetDeliveryPolicy::PolicyType[:DynamicEnvelopeEncryption],
  configuration: JSON.generate([{Key: AzureMediaService::AssetDeliveryPolicy::ConfigurationKey[:EnvelopeBaseKeyAcquisitionUrl], Vlaue: key_delivery_url}])
})
asset.delivery_policy_link(delivery_policy)

asset.publish(expire_minutes: 43200)
```

## Contributing

1. Fork it ( https://github.com/murayama/azure_media_service_ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
