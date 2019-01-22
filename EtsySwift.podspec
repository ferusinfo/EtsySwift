Pod::Spec.new do |s|

  s.name         = "EtsySwift"
  s.version      = "0.0.3"
  s.summary      = "Small library allowing reactive authorization with Etsy"
  s.homepage     = "https://github.com/ferusinfo/EtsySwift"
  s.license      = "MIT"

  s.author             = { "Maciej Kołek" => "hello@ferus.info" }
  s.social_media_url   = "http://twitter.com/ferusinfo"
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/ferusinfo/EtsySwift.git", :tag => "#{s.version}" }
  s.swift_version = "4.2"

  s.source_files  = ["Classes/Etsy/*/*", "Classes/Etsy/*"]
  s.dependency 'Alamofire', '~> 4.7.3'
  s.dependency 'RxAlamofire', '~> 4.2.0'
  s.dependency 'RxSwift', '4.4.0'
end