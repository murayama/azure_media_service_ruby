# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'azure_media_service/version'

Gem::Specification.new do |spec|
  spec.name          = "azure_media_service"
  spec.version       = AzureMediaService::VERSION
  spec.authors       = ["murayama"]
  spec.email         = ["mura869@gmail.com"]
  spec.summary       = %q{Azure Media Service SDK for ruby}
  spec.description   = %q{Azure Media Service SDK for ruby}
  spec.homepage      = "https://github.com/murayama/azure_media_service_ruby"
  spec.license       = "MIT"
  spec.required_ruby_version =  ">= 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "mime-types"
  spec.add_dependency "builder"
end
