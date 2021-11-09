#
# Be sure to run `pod lib lint AnimatableStackView.podspec` to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AnimatableStackView'
  s.version          = '4.0.5'
  s.summary          = 'UIStackView based class that allows to animate its changes. Curently supports vertical animations only.'

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

  s.ios.deployment_target = '9.0'
  s.swift_versions = ['5.0']
  s.source_files = 'AnimatableStackView/Classes/**/*'
  s.frameworks = 'Foundation', 'UIKit'
  s.dependency 'RoutableLogger'
end
