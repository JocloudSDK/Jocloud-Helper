#
#  Be sure to run `pod spec lint video_sameChannel.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

 spec.name         = "feedback"
 spec.version      = "0.0.1"
 spec.summary      = "A short description of feedback."
 spec.platform     = :ios, "10.0" #平台及支持的最低版本
 spec.description  = <<-DESC
     A short description of feedback.A short description of feedback.
                     DESC

 spec.homepage     = "https://git.yy.com/apps/scenesdemo/aivacomadvancescene-ios"
 spec.license      = 'MIT'
 spec.author       = { "chugaopeng" => "chugaopeng@yy.com" }
 spec.source       = { :git => "https://git.yy.com/apps/scenesdemo/aivacomadvancescene-ios.git", :tag => "#{spec.version}" }
 spec.source_files  = "feedback/Demo/*.{h,m}"
 
 spec.dependency 'Masonry'
 spec.dependency 'baseui'
 spec.dependency 'utils'
 spec.dependency 'jly_logcat'
 spec.dependency 'AFNetworking', '~> 3.2.1'
 spec.dependency 'SSZipArchive', '~>1.8.1'
 
end
