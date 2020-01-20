Pod::Spec.new do |s|

  s.name        = "Proposer"
  s.version     = "1.2.3"
  s.summary     = "Make permission request easier."

  s.description = <<-DESC
                   Proposer provides a single API to request permission for access Camera, Photos, Microphone, Contacts, Reminders, Calender, Location or Notifications.
                   DESC

  s.homepage    = "https://github.com/nixzhu/Proposer"

  s.license     = { :type => "MIT", :file => "LICENSE" }

  s.authors           = { "nixzhu" => "zhuhongxu@gmail.com" }
  s.social_media_url  = "https://twitter.com/nixzhu"

  s.ios.deployment_target   = "8.0"

  s.source          = { :git => "https://github.com/nixzhu/Proposer.git", :tag => s.version }
  s.source_files    = "Proposer/*.swift"
  s.requires_arc    = true

end
