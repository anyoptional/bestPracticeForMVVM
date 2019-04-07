#
# Be sure to run `pod lib lint SwiftyHUD.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    
    s.name             = 'SwiftyHUD'
    s.version          = '1.0.0'
    s.summary          = 'Application error handing module.'
    
    s.homepage         = 'Coming soon...'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Archer' => 'code4archer@163.com' }
    s.source           = { :git => 'Coming soon...', :tag => s.version.to_s }
    
    s.ios.deployment_target = '8.0'
    s.dependency 'MBProgressHUD', '~> 1.1.0'

    s.resource_bundles = {
        'SwiftyHUD' => ['SwiftyHUD/Assets/*.png']
    }
    
    s.subspec "Core" do |cs|
        cs.source_files  = "SwiftyHUD/Classes/Core"
    end
    
end
