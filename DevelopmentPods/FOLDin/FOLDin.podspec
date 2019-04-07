#
# Be sure to run `pod lib lint FOLDin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'FOLDin'
    s.version          = '1.0.0'
    s.summary          = 'Application custom UI module.'
    
    s.homepage         = 'Coming soon...'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Archer' => 'code4archer@163.com' }
    s.source           = { :git => 'Coming soon...', :tag => s.version.to_s }
    
    s.frameworks  = "UIKit"
    s.dependency 'FDNamespacer'
    
    s.ios.deployment_target = '8.0'
    
    s.public_header_files = "FOLDin/Classes/FDNavigationBar/*.h"
    
    s.swift_version = '4.2'
    
    s.subspec "Core" do |cs|
        cs.source_files  = "FOLDin/Classes/UIKit+Ex"
    end
    
    s.subspec "PopupView" do |cs|
        cs.source_files  = "FOLDin/Classes/FDPopupView"
    end
    
    s.subspec "TextField" do |cs|
      cs.source_files  = "FOLDin/Classes/TextField"
    end
    
    s.subspec "NavigationBar" do |cs|
        cs.source_files  = "FOLDin/Classes/FDNavigationBar"
    end
    
    s.subspec "ProgressBar" do |cs|
        cs.source_files  = "FOLDin/Classes/FDProgressBar"
    end
    
    s.subspec "PlaceholderView" do |cs|
        cs.source_files  = "FOLDin/Classes/FDPlaceholderView"
    end
    
end
