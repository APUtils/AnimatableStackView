# Change Log
All notable changes to this project will be documented in this file.
`AnimatableView` adheres to [Semantic Versioning](http://semver.org/).


## [6.0.0](https://github.com/APUtils/AnimatableStackView/releases/tag/6.0.0)
Released on 2023-11-02.

#### Changed
- Spec name `AnimatableStackView` > `AnimatableView`
- iOS 12.0 min

#### Removed
- AnimatableStackView


## [5.0.0](https://github.com/APUtils/AnimatableStackView/releases/tag/5.0.0)
Released on 2023-11-02.

#### Added
- Accessibility ID for zero height view
- Added postLayout parameter for update call
- Added reusable views pool to improve performance
- Allow to search views by ID
- AnimatableView .getView(identity:)
- AnimatableView as simplified and more performant version of AnimatableStackView with slightly different animations
- AnimatableView spec
- Autoresize mask disable info log
- Duplicated IDs error
- Duplicated IDs report
- Error logs to RoutableLogger
- Example for pods project
- ID mismatch checks
- RoutableLogger dependency
- SPM support

#### Changed
- configure -> update
- Disable autoresize mask for animatable view subviews
- Excessive params remove
- Force stack view and subviews layout during animation to know final positions
- Helper method to create configured view from view model
- Increased amounts of VMs for tests
- iOS 11.0 minimum
- Made view pools local
- Optimized view remove
- Preserve frame origin Y during layouts
- Scripts update
- Slightly changed protocols
- viewModel -> animatableViewModel

#### Fixed
- AnimatableView reuse crash fix
- Build
- Carthage
- CI
- Documentation warnings
- Fixed configuration and fade out alphas conflict
- Fixed existing view reconfiguration
- Fixed invisible view reuse
- Fixed layout flow in non-animation closure during animation
- Prevent double reuse
- Scripts
- Tests
- View layout on creation fix
- View reconfiguration fix
- Warnings

#### Improved
- Better code reuse
- Better error log for duplicate IDs
- Improved reconfiguration animation during reuse for animatable view
- Improved views reuse for animatable view
- Initial update optimizations
- Non-animated update optimization
- Safer subviews-only layout
- Simplified AnimatableView_ViewModel conformance
- Simplified checking for changes method
- Slightly improved getting view from a pool
- Using constraint for zero height view as more robust solution

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
