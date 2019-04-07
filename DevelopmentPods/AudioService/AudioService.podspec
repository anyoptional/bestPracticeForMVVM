#
# Be sure to run `pod lib lint AudioService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  
  s.name             = 'AudioService'
  s.version          = '1.0.0'
  s.summary          = 'Application audio service module.'
  
  s.homepage         = 'Coming soon...'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Archer' => 'code4archer@163.com' }
  s.source           = { :git => 'Coming soon...', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'
  s.dependency 'Fatal'
  s.dependency 'RxSwift', '~> 4.4.2'
  s.dependency 'RxMoya'
  
  s.public_header_files = 'AudioService/Classes/Core/*.h'
  s.vendored_frameworks = 'AudioService/Classes/Vendor/*.framework'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }
  
  s.subspec "Core" do |cs|
    cs.source_files  = "AudioService/Classes/Core"
  end
  
  s.subspec "AudioPlayer" do |cs|
    cs.source_files  = "AudioService/Classes/AudioPlayer"
  end
  
end
