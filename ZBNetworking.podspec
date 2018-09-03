#
#  Be sure to run `pod spec lint ZBNetworking.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ZBNetWorking"
  s.version      = "1.0.1"
  s.summary      = "The network request library adds caching policies."

  s.homepage     = "https://github.com/Suzhibin/ZBNetworking"

  s.license      = { :type => "MIT", :file => "FILE_LICENS" }

  s.author             = { "Suzhibin" => "szb2323@163.com" }

  s.ios.deployment_target = "7.0"

  s.source       = { :git => "https://github.com/Suzhibin/ZBNetworking.git", :tag => "1.0.1" }

  s.source_files  = "ZBNetworking/**/*.{h,m}"
  s.exclude_files = "ZBNetworking/ZBNetworking.h"
  s.requires_arc = true

  s.dependency "AFNetworking", "~> 3.1.0"

end
