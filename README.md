# AnimatableStackView

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/AnimatableStackView.svg?style=flat)](http://cocoapods.org/pods/AnimatableStackView)
[![License](https://img.shields.io/cocoapods/l/AnimatableStackView.svg?style=flat)](http://cocoapods.org/pods/AnimatableStackView)
[![Platform](https://img.shields.io/cocoapods/p/AnimatableStackView.svg?style=flat)](http://cocoapods.org/pods/AnimatableStackView)
[![CI Status](http://img.shields.io/travis/APUtils/AnimatableStackView.svg?style=flat)](https://travis-ci.org/APUtils/AnimatableStackView)

UIStackView based class that allows to animate its changes

## Example

Clone the repo and then open `Carthage Project/AnimatableStackView.xcodeproj`

## GIF animation

<img src="Gifs/1.gif"/>

## Installation

#### Carthage

Please check [official guide](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos)

Cartfile:

```
github "APUtils/AnimatableStackView" ~> 4.0
```

#### CocoaPods

AnimatableStackView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AnimatableStackView', '~> 4.0'
```

## Usage

Just call `.configure(viewModels:)` method with new view models and then perform layout inside animation block:
```swift
UIView.animate(withDuration: 2) {
    self.stackView.configure(viewModels: self.vms1)
    self.view.layoutIfNeeded()
}
```

See example and test projects for more details.

## Contributions

Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

## Author

Anton Plebanovich, anton.plebanovich@gmail.com

## License

AnimatableStackView is available under the MIT license. See the LICENSE file for more info.
