# Change Log
All notable changes to this project will be documented in this file.
`AnimatableStackView` adheres to [Semantic Versioning](http://semver.org/).

## [4.0.5](https://github.com/APUtils/AnimatableStackView/releases/tag/4.0.5)
Released on 09/04/2020.

#### Fixed
- Fixed possible broken animations during view creation
- Fixed view insertion animation


## [4.0.4](https://github.com/APUtils/AnimatableStackView/releases/tag/4.0.4)
Released on 09/18/2019.

#### Added
- Added description about vertical animations only.


## [4.0.3](https://github.com/APUtils/AnimatableStackView/releases/tag/4.0.3)
Released on 09/18/2019.

#### Fixed
- Fixed collapsing into zero height animation


## [4.0.2](https://github.com/APUtils/AnimatableStackView/releases/tag/4.0.2)
Released on 07/24/2019.

#### Fixed
- Fixed zero height stack view relayout case


## [4.0.1](https://github.com/APUtils/AnimatableStackView/releases/tag/4.0.1)
Released on 07/22/2019.

#### Fixed
- Fixed zero height stack view layout case


## [4.0.0](https://github.com/APUtils/AnimatableStackView/releases/tag/4.0.0)
Released on 07/22/2019.

#### Added
- Added view based testing
- Added layout spec
- Added constraints update call at the end of configuration to support reconfiguration in cells

#### Changed
- Renamed View into Subview


## [3.0.0](https://github.com/APUtils/AnimatableStackView/releases/tag/3.0.0)
Released on 07/11/2019.

#### Added
- Documentation
- Method to get view by ID

#### Changed
- Made views accessible
- Made cell class instance property so view model could have different cells
- Rearranged configuration calls so setup happens after reattaching to not break possible animations
- Made everything open to be able to override if needed


## [2.0.0](https://github.com/APUtils/AnimatableStackView/releases/tag/2.0.0)
Released on 07/09/2019.

#### Changed
- Create and Configure protocols takes Any as a parameter
- AnimatableStackView is able to work with any kind of views together


## [1.0.0](https://github.com/APUtils/AnimatableStackView/releases/tag/1.0.0)
Released on 07/09/2019.

#### Added
- Initial release of AnimatableStackView.
  - Added by [Anton Plebanovich](https://github.com/anton-plebanovich).
