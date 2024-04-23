Pod::Spec.new do |spec|
  spec.name         = "StubNetworkKit"
  spec.version      = ENV['POD_VERSION']
  spec.summary      = "100% pure Swift library to stub network requests."
  spec.description  = <<-DESC
                  **100% pure Swift** library to stub network requests.

                  **100% pure Swift** means, 
                  - No more Objective-C API
                  - Testable also in other than Apple platform (e.g. Linux)
                  DESC

  spec.homepage     = "https://github.com/417-72KI/StubNetworkKit"
  spec.license      = "MIT"

  spec.author             = { "417-72KI" => "417.72ki@gmail.com" }
  spec.social_media_url   = "https://twitter.com/417_72ki"

  spec.ios.deployment_target     = "15.0"
  spec.osx.deployment_target     = "12.0"
  # spec.watchos.deployment_target = "8.0"
  spec.tvos.deployment_target    = "15.0"

  spec.source         = { :git => "https://github.com/417-72KI/#{spec.name}.git", :tag => "#{spec.version}" }
  spec.source_files   = 'Sources/StubNetworkKit/**/*.swift'
  spec.swift_versions = ['5.8', '5.9', '5.10']

  spec.frameworks     = 'Foundation'
  spec.dependency 'MultipartFormDataParser', '~> 2.2.0'
end
