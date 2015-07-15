Pod::Spec.new do |s|

  s.name        = "Proposer"
  s.version     = "0.6.2"
  s.summary     = "Make permission request easier."

  s.description = <<-DESC
                   Proposer provides a simple API to request permission for access Camera, Photos, Microphone, Contacts, Location.
                   DESC

  s.homepage    = "https://github.com/nixzhu/Proposer"

  s.license     = { :type => "MIT", :file => "LICENSE" }

  s.authors           = { "nixzhu" => "zhuhongxu@gmail.com" }
  s.social_media_url  = "https://twitter.com/nixzhu"

  s.ios.deployment_target   = "8.0"
  # s.osx.deployment_target = "10.7"

  s.source          = { :git => "https://github.com/nixzhu/Proposer.git", :tag => s.version }
  s.source_files    = "Proposer/*.swift"
  s.requires_arc    = true

end
