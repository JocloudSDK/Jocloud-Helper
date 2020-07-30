#
#  Be sure to run `pod spec lint video_sameChannel.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

 spec.name         = "video_crosschannel"
 spec.version      = "0.0.1"
 spec.summary      = "A short description of video_crosschannel."
 spec.platform     = :ios, "10.0" #平台及支持的最低版本
 spec.description  = <<-DESC
     A short description of video_crosschannel.A short description of video_crosschannel.
                     DESC

 spec.homepage     = "https://git.yy.com/apps/scenesdemo/aivacomadvancescene-ios"
 spec.license      = 'MIT'
 spec.author       = { "chugaopeng" => "chugaopeng@yy.com" }
 spec.source       = { :git => "https://git.yy.com/apps/scenesdemo/aivacomadvancescene-ios.git", :tag => "#{spec.version}" }
 spec.source_files  = "video_crosschannel/Demo/*.{h,m}"
 
 spec.dependency 'baseui'
 spec.dependency 'utils'
 spec.dependency 'common'
 spec.dependency 'jly_rtc'
 spec.dependency 'jly_rts'
 spec.dependency 'jly_logcat'
 spec.dependency 'feedback'
 spec.dependency 'Masonry'
 
end
