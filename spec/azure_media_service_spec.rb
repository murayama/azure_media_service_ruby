require 'spec_helper'

describe AzureMediaService do
  context '#configure should allow to set' do
    it 'id' do
      AzureMediaService.configure do |config|
        config.id = 'client_id'
      end

      expect(AzureMediaService.id).to eq('client_id')
    end

    it 'secret' do
      AzureMediaService.configure do |config|
        config.secret = 'client_secret'
      end

      expect(AzureMediaService.secret).to eq('client_secret')
    end

    it 'token_uri' do
      AzureMediaService.configure do |config|
        config.token_uri = 'https://login.microsoft.com/tenant-id-goes-here/oauth2/token'
      end

      expect(AzureMediaService.token_uri).to eq('https://login.microsoft.com/tenant-id-goes-here/oauth2/token')
    end

    it 'media_uri' do
      AzureMediaService.configure do |config|
        config.media_uri = 'https://media-service-name.restv2.westeurope.media.azure.net/api/'
      end

      expect(AzureMediaService.media_uri).to eq('https://media-service-name.restv2.westeurope.media.azure.net/api/')
    end

    it 'api_version' do
      AzureMediaService.configure do |config|
        config.api_version = '2.17'
      end

      expect(AzureMediaService.api_version).to eq('2.17')
    end
  end
end