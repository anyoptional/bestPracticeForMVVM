#
# Be sure to run `pod lib lint AppMusic.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  
  s.name             = 'AppMusic'
  s.version          = '1.0.0'
  s.summary          = 'Application music module.'
  
  s.homepage         = 'Coming soon...'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Archer' => 'code4archer@163.com' }
  s.source           = { :git => 'Coming soon...', :tag => s.version.to_s }
  
  s.ios.deployment_target = '9.0'
  
  s.dependency 'Fate'
  s.dependency 'RxMoya'
  s.dependency 'FOLDin'
  s.dependency 'Mediator'
  s.dependency 'SwiftyHUD'
  s.dependency 'AudioService'
  
  s.dependency 'YYKit', '~> 1.0.9'
  s.dependency 'SnapKit', '~> 4.2.0'
  s.dependency 'SkeletonView', '~> 1.4.2'
  s.dependency 'RxSwift', '~> 4.4.2'
  s.dependency 'RxCocoa', '~> 4.4.2'
  s.dependency 'RxOptional', '~> 3.6.2'
  s.dependency 'RxSwiftExt', '~> 3.4.0'
  s.dependency 'MJRefresh', '~> 3.1.15.7'
  s.dependency 'SDCycleScrollView', '~> 1.75'

  s.resource_bundles = {
    'AppMusic' => ['AppMusic/Assets/*.{png,jpg}']
  }
  
  s.subspec "Controller" do |cs|
    cs.source_files  = "AppMusic/Classes/Controller"
  end
  
  s.subspec "ViewModel" do |cs|
    cs.source_files  = "AppMusic/Classes/ViewModel"
  end
  
  s.subspec "View" do |cs|
    cs.source_files  = "AppMusic/Classes/View"
  end
  
  s.subspec "Model" do |cs|
    cs.source_files  = "AppMusic/Classes/Model"
  end
  
  s.subspec "Utility" do |cs|
    cs.source_files  = "AppMusic/Classes/Utility"
  end
  
  s.subspec "DataSource" do |cs|
    cs.source_files  = "AppMusic/Classes/DataSource"
  end
  
end
