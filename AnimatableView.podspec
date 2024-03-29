#
# Be sure to run `pod lib lint AnimatableView.podspec` to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AnimatableView'
  s.version          = '6.0.2'
  s.summary          = 'AnimatableView that works like a UIStackView but has better animations'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
UIStackView based class that provides a convenience interface to animate its content. Curently supports vertical animations only.
                       DESC

  s.homepage         = 'https://github.com/APUtils/AnimatableStackView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anton Plebanovich' => 'anton.plebanovich@gmail.com' }
  s.source           = { :git => 'https://github.com/APUtils/AnimatableStackView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_versions = ['5']
  
  # 1.12.0: Ensure developers won't hit CocoaPods/CocoaPods#11402 with the resource
  # bundle for the privacy manifest.
  # 1.13.0: visionOS is recognized as a platform.
  s.cocoapods_version = '>= 1.13.0'
  
  s.source_files = 'AnimatableView/Classes/**/*'
  s.resource_bundle = {"AnimatableView.privacy"=>"AnimatableView/Privacy/PrivacyInfo.xcprivacy"}
  s.frameworks = 'Foundation', 'UIKit'
  s.dependency 'RoutableLogger'
end
