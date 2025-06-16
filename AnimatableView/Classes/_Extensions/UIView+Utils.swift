//
//  UIView+Utils.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/22/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

extension UIView {
    
    var _isVisible: Bool { !isHidden && alpha >= 0.01 }
    
    func _layoutHeight(y: CGFloat = 0, width: CGFloat) {
        let height = _fixedSystemLayoutSizeFitting(
            .init(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .init(0.001)
        ).height
        
        let frame = CGRect(x: 0, y: y, width: width, height: height)
        
        if self.frame != frame {
            self.frame = frame
        }
    }
    
    /// Preserve view's size using autoresizing mask during layout.
    func _layoutSubviewsOnly() {
        guard !subviews.isEmpty else { return }
        
        let activeOuterConstraints = _getOuterConstraints().filter { $0.isActive }
        
        // Disable outer constraints to prevent broken constraints during layout
        if !activeOuterConstraints.isEmpty {
            NSLayoutConstraint.deactivate(activeOuterConstraints)
        }
        
        if translatesAutoresizingMaskIntoConstraints {
            layoutIfNeeded()
            
        } else {
            // Fix view position and size during layout using autoresize mask
            translatesAutoresizingMaskIntoConstraints = true
            layoutIfNeeded()
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Restore outer constraints
        if !activeOuterConstraints.isEmpty {
            NSLayoutConstraint.activate(activeOuterConstraints)
        }
    }
    
    /// Get all constraints to `self` from outer view hierarchy.
    func _getOuterConstraints() -> [NSLayoutConstraint] {
        _superviews
            .flatMap { $0._constraints(to: self) }
            .sorted { $0.priority > $1.priority }
    }
    
    /// Returns contraints to a `view` that source view owns.
    /// - Parameter view: A view to use for a check.
    func _constraints(to view: UIView) -> [NSLayoutConstraint] {
        constraints.filter { $0.firstItem === view || $0.secondItem === view }
    }
    
#if compiler(>=5)
    /// All view superviews to the top most
    var _superviews: DropFirstSequence<UnfoldSequence<UIView, (UIView?, Bool)>> {
        return sequence(first: self, next: { $0.superview }).dropFirst(1)
    }
#else
    /// All view superviews to the top most
    var _superviews: AnySequence<UIView> {
        return sequence(first: self, next: { $0.superview }).dropFirst(1)
    }
#endif
    
    var _allSubviews: [UIView] {
        var allSubviews = self.subviews
        allSubviews.forEach { allSubviews.append(contentsOf: $0._allSubviews) }
        return allSubviews
    }
}


private var c_fadedOutAssociationKey = 0

extension UIView {
    
    static var _isAnimating: Bool { inheritedAnimationDuration > 0 }
    
    /// Returns `true` if view can be animated.
    /// That means `window` is not `nil` and application state is `.active`.
    var _isAnimatable: Bool {
        return window != nil && UIApplication.shared.applicationState == .active
    }
    
    func _animateFadeInIfNeeded() {
        // Nothing to animate if not visible or not animatable
        guard UIView._isAnimating, _isVisible, _isAnimatable else { return }
        
        layer.removeAnimation(forKey: "opacity")
        let originalAlpha = alpha
        UIView.performWithoutAnimation {
            alpha = 0
        }
        alpha = originalAlpha
    }
    
    var _originalAlpha: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &c_fadedOutAssociationKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &c_fadedOutAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func _performNonAnimatedForInvisible(_ closure: () -> Void) {
        if let presentation = layer.presentation() {
            if presentation.isHidden || presentation.opacity < 0.01 {
                // Invisible during animation
                layer._removeAllAnimationsRecursively()
                UIView.performWithoutAnimation {
                    closure()
                }
            } else {
                closure()
            }
            
        } else {
            // No presentation layer for some reason
            if _isVisible {
                // Just visible
                closure()
                
            } else {
                // Just invisible
                UIView.performWithoutAnimation {
                    closure()
                }
            }
        }
    }
    
    @available(iOS 8.0, *)
    func _fixedSystemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        if constraints.isEmpty {
            let width: CGFloat
            if targetSize.width > intrinsicContentSize.width {
                if contentHuggingPriority(for: .horizontal) > horizontalFittingPriority {
                    width = intrinsicContentSize.width
                } else {
                    width = targetSize.width
                }
                
            } else {
                if contentCompressionResistancePriority(for: .horizontal) > horizontalFittingPriority {
                    width = intrinsicContentSize.width
                } else {
                    width = targetSize.width
                }
            }
            
            let height: CGFloat
            if targetSize.height > intrinsicContentSize.height {
                if contentHuggingPriority(for: .vertical) > verticalFittingPriority {
                    height = intrinsicContentSize.height
                } else {
                    height = targetSize.height
                }
                
            } else {
                if contentCompressionResistancePriority(for: .vertical) > verticalFittingPriority {
                    height = intrinsicContentSize.height
                } else {
                    height = targetSize.height
                }
            }
            
            return .init(width: width, height: height)
            
        } else {
            return systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        }
    }
}
