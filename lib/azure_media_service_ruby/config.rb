module AzureMediaServiceRuby
  class Config
    UPLOAD_LIMIT_SIZE = 4194304 # 4MB
    READ_BUFFER_SIZE       = 4000000

    MEDIA_URI = "https://wamsos1clus001rest-hs.cloudapp.net/api/"
    TOKEN_URI = "https://wamsprodglobal001acs.accesscontrol.windows.net/v2/OAuth2-13"

  end
end
