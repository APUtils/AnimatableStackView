//
//  AnimatableView.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/2/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit

/// Subview that can be created with view model and has an ID.
public protocol AnimatableView_Subview: UIView, CreatableWithViewModel, Identifiable {
    var animatableViewModel: Any? { get }
}

/// View model that has ID and view class to which it belong.
public protocol AnimatableView_ViewModel: Identifiable {
    var animatableViewClass: AnimatableView_Subview.Type { get }
    func hasChanges(from viewModel: AnimatableView_ViewModel) -> Bool
}

extension AnimatableView_ViewModel {
    func hasChanges(from viewModel: AnimatableView_ViewModel) -> Bool { true }
}

/// View that groups subviews in the vertical stack and animates chages.
/// Just perform changes using `update(viewModels:postLayout:)`
/// and then call `view.layoutIfNeeded()` inside animation block.
open class AnimatableView: UIView {
    
    /// View model that has ID and view class to which it belong.
    public typealias ViewModel = AnimatableView_ViewModel
    
    /// Subview that can be created with view model and has an ID.
    public typealias Subview = AnimatableView_Subview
    
    // ******************************* MARK: - Properties
    
    private var previousViewModels: [ViewModel] = []
    
    /// Array of `Views` that animatable view is currently displaying. View is considered visible if it's
    /// alpha is more than or equal to 0.01 and `isHidden` property is `false.`
    /// - warning: You should not check `subviews` property since it contains reusable and invisible views
    /// and their position and order might be ambiguous in that state.
    public private(set) var visibleViews: [Subview] = []
    
    /// - warning: You should not check `subviews` property since it contains reusable and invisible views
    /// and their position and order might be ambiguous in that state.
    open override var subviews: [UIView] { super.subviews }
    
    private let viewsPool = ViewsPool()
    
    // ******************************* MARK: - Initialization and Setup
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
    
    // ******************************* MARK: - UIView Overrides
    
    open override var intrinsicContentSize: CGSize { .zero }
    
    // ******************************* MARK: - Methods
    
    /// Core method to update view's subviews.
    /// May be called inside animation block.
    /// If called inside animation block `layoutIfNeeded()` should be called on base view,
    /// e.g. view controller's view for animations to work.
    /// for animations to work.
    /// - parameter viewModels: View models that will be used to configure a new state.
    /// Views will be reused or created whenever needed and properly attached so animation will be smooth.
    open func update(viewModels: [ViewModel]) {
        
        func beforeReuse(view: UIView) {
            // Restore original alpha
            if let originalAlpha = view.originalAlpha {
                view.alpha = originalAlpha
            }
        }
        
        func afterReuse(view: UIView, previousView: UIView, hasChanges: Bool) {
            // Ignore invisible views
            guard view.isVisible else { return }
            
            view.performNonAnimatedForInvisible {
                let y = previousView == self ? 0 : previousView.frame.maxY
                if hasChanges {
                    let height = view.fixedSystemLayoutSizeFitting(.init(width: bounds.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .init(0.001)).height
                    let frame = CGRect(x: 0, y: y, width: bounds.width, height: height)
                    view.frame = frame
                    view.layoutSubviewsOnly()
                } else {
                    view.frame.origin.y = y
                }
                
                // Sned to back so new views will slide from under existing ones.
                sendSubviewToBack(view)
            }
        }
        
        // Reusing views with the same ID first
        let existingReusableViews: [String: (Subview, Bool)] = viewModels.dictionaryMap { viewModel in
            var hasChanges = true
            if let view = viewsPool.getExisting(viewModel: viewModel, beforeReuse: beforeReuse, afterReuse: { _, _hasChanges in hasChanges = _hasChanges } ) {
                return (viewModel.id, (view, hasChanges))
            } else {
                return nil
            }
        }
        
        let previousViews = visibleViews
        var newViews: [Subview] = []
        var previousView: UIView = self
        var constraints: [NSLayoutConstraint] = []
        
        viewModels.forEach { viewModel in
            var view: Subview!
            if let existingView = visibleViews.first(where: { $0.id == viewModel.id }) {
                // Update
                view = existingView
                view.configure(viewModel: viewModel)
                
            } else if let (existingReusableView, hasChanges) = existingReusableViews[viewModel.id] {
                // Reuse existing
                afterReuse(view: existingReusableView, previousView: previousView, hasChanges: hasChanges)
                view = existingReusableView
                view.animateFadeInIfNeeded()
                
            } else {
                
                // Reuse or creation
                view = viewsPool.get(viewModel: viewModel, onCreation: { view in
                    afterReuse(view: view, previousView: previousView, hasChanges: true)
                    
                    // Insert at 0 so new views will slide from under existing ones.
                    insertSubview(view, at: 0)
                    
                    constraints.append(view.leadingAnchor.constraint(equalTo: leadingAnchor))
                    constraints.append(view.trailingAnchor.constraint(equalTo: trailingAnchor))
                }, beforeReuse: beforeReuse, afterReuse: { afterReuse(view: $0, previousView: previousView, hasChanges: $1) })
                
                view.animateFadeInIfNeeded()
            }
            
            // Ignore invisible views
            guard view.isVisible else { return }
            
            let anchor = previousView === self ? topAnchor : previousView.bottomAnchor
            view.constraintFromTopIfNeeded(to: previousView, anchor: anchor, in: self).flatMap { constraints.append($0) }
            
            previousView = view
            newViews.append(view)
        }
        
        let anchor = previousView === self ? topAnchor : previousView.bottomAnchor
        constraintFromBottomIfNeeded(to: previousView, anchor: anchor, in: self).flatMap { constraints.append($0) }
        
        NSLayoutConstraint.activate(constraints)
        
        /// Find removed views
        let removedViews = previousViews
            .filter { previousView in !newViews.contains { $0 === previousView } }
            
        /// Fade out
        removedViews.forEach {
            if $0.isVisible {
                $0.originalAlpha = $0.alpha
                $0.alpha = 0
            }
        }
        
        viewsPool.add(removedViews)
        
        visibleViews = newViews
    }
    
    // ******************************* MARK: - Other Public Methods
    
    /// Find view that corresponds to passed identity. E.g. you can pass view model and get view for that.
    open func getView(identity: Identifiable) -> Subview? {
        return subviews
            .compactMap { $0 as? Subview }
            .first { $0.id == identity.id }
    }
}

private var c_topConstraintAssociationKey = 0
private var c_bottomConstraintAssociationKey = 0

private extension UIView {
    
    private var topConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &c_topConstraintAssociationKey) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &c_topConstraintAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var bottomConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &c_bottomConstraintAssociationKey) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &c_bottomConstraintAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func constraintFromTopIfNeeded(to view: UIView, anchor: NSLayoutYAxisAnchor, in hostView: UIView) -> NSLayoutConstraint? {
        if let existingConstraint = topConstraint {
            if existingConstraint.secondItem !== view || !existingConstraint.isActive {
                existingConstraint.isActive = false
                topConstraint = topAnchor.constraint(equalTo: anchor)
                return topConstraint
            } else {
                return nil
            }
            
        } else {
            topConstraint = topAnchor.constraint(equalTo: anchor)
            return topConstraint
        }
    }
    
    func constraintFromBottomIfNeeded(to view: UIView, anchor: NSLayoutYAxisAnchor, in hostView: UIView) -> NSLayoutConstraint? {
        if let existingConstraint = bottomConstraint {
            if existingConstraint.secondItem !== view {
                existingConstraint.isActive = false
                bottomConstraint = bottomAnchor.constraint(equalTo: anchor)
                return bottomConstraint
            } else {
                return nil
            }
            
        } else {
            bottomConstraint = bottomAnchor.constraint(equalTo: anchor)
            return bottomConstraint
        }
    }
}

private extension CGFloat {
    
    /// Returns this value rounded to a pixel value using the specified rounding rule.
    /// Uses `.toNearestOrAwayFromZero` by default.
    /// - returns: The integral value found by rounding using rule.
    func roundedToPixel(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGFloat {
        let scale = UIScreen.main.scale
        return (self * scale).rounded(rule) / scale
    }
}

private final class ViewsPool {
    
    typealias ViewClosure = (AnimatableView.Subview) -> Void
    typealias HasChangesClosure = (AnimatableView.Subview, Bool) -> Void
    
    // TODO: Can be improved by using dictionary but we need a performant way of converting `viewClass` to a hash.
    private var views: [AnimatableView.Subview] = []
    
    func add(_ views: [AnimatableView.Subview]) {
        self.views.append(contentsOf: views)
    }
    
    func getExisting(viewModel: AnimatableView.ViewModel, beforeReuse: ViewClosure = { _ in }, afterReuse: HasChangesClosure = { _, _ in }) -> AnimatableView.Subview? {
        if let existingViewIndex = views.firstIndex(where: { $0.id == viewModel.id }) {
            /// Found reusable view with the same ID. Checking if it requires reconfiguration.
            let existingView = views.remove(at: existingViewIndex)
            existingView.performNonAnimatedForInvisible {
                beforeReuse(existingView)
                if let existingViewModel = existingView.animatableViewModel as? AnimatableView.ViewModel {
                    if viewModel.hasChanges(from: existingViewModel) {
                        existingView.configure(viewModel: viewModel)
                        afterReuse(existingView, true)
                    } else {
                        afterReuse(existingView, false)
                    }
                    
                } else {
                    existingView.configure(viewModel: viewModel)
                    afterReuse(existingView, true)
                }
            }
            return existingView
            
        } else {
            return nil
        }
    }
    
    func get(viewModel: AnimatableView.ViewModel, onCreation: ViewClosure = { _ in }, beforeReuse: ViewClosure = { _ in }, afterReuse: HasChangesClosure = { _, _ in }) -> AnimatableView.Subview {
        
        if let existingViewIndex = views.firstIndex(where: { $0.id == viewModel.id }) {
            /// Found reusable view with the same ID. Checking if it requires reconfiguration.
            let existingView = views.remove(at: existingViewIndex)
            existingView.performNonAnimatedForInvisible {
                beforeReuse(existingView)
                if let existingViewModel = existingView.animatableViewModel as? AnimatableView.ViewModel {
                    if viewModel.hasChanges(from: existingViewModel) {
                        existingView.configure(viewModel: viewModel)
                        afterReuse(existingView, true)
                    } else {
                        afterReuse(existingView, false)
                    }
                    
                } else {
                    existingView.configure(viewModel: viewModel)
                    afterReuse(existingView, true)
                }
            }
            return existingView
            
        } else if let existingView = views.reversed().first(where: { type(of: $0) == viewModel.animatableViewClass }) {
            /// Found reusable view of the same class. Reconfigure and use.
            if let existingViewIndex = views.firstIndex(where: { $0 === existingView }) {
                views.remove(at: existingViewIndex)
            }
            
            existingView.performNonAnimatedForInvisible {
                beforeReuse(existingView)
                existingView.configure(viewModel: viewModel)
                afterReuse(existingView, true)
            }
            
            return existingView
            
        } else {
            /// Create new configured view and return.
            var view: AnimatableView.Subview!
            UIView.performWithoutAnimation {
                view = viewModel.animatableViewClass.create(viewModel: viewModel)
                onCreation(view)
            }
            return view
        }
    }
}


// ******************************* MARK: - Scripting

extension Sequence {
    
    @inlinable func dictionaryMap<T, U>(_ transform: (_ element: Iterator.Element) throws -> (T, U)?) rethrows -> [T: U] {
        return try self.reduce(into: [T: U]()) { dictionary, element in
            guard let (key, value) = try transform(element) else { return }
            
            dictionary[key] = value
        }
    }
}

private var c_fadedOutAssociationKey = 0

private extension UIView {
    
    static var isAnimating: Bool { inheritedAnimationDuration > 0 }
    
    /// Returns `true` if view can be animated.
    /// That means `window` is not `nil` and application state is `.active`.
    var isAnimatable: Bool {
        return window != nil && UIApplication.shared.applicationState == .active
    }
    
    func animateFadeInIfNeeded() {
        // Nothing to animate if not visible or not animatable
        guard isVisible, isAnimatable else { return }
        
        if UIView.isAnimating {
            let originalAlpha = alpha
            UIView.performWithoutAnimation {
                alpha = 0
            }
            alpha = originalAlpha
        }
    }
    
    var originalAlpha: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &c_fadedOutAssociationKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &c_fadedOutAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func performNonAnimatedForInvisible(_ closure: () -> Void) {
        if let presentation = layer.presentation() {
            if presentation.isHidden || presentation.opacity < 0.01 {
                // Invisible during animation
                layer.removeAllAnimationsRecursively()
                UIView.performWithoutAnimation {
                    closure()
                }
            } else {
                closure()
            }
            
        } else {
            // No presentation layer for some reason
            if isVisible {
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
    func fixedSystemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
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

extension CALayer {
    
    func removeAllAnimationsRecursively() {
        removeAllAnimations()
        sublayers?.forEach { $0.removeAllAnimationsRecursively() }
    }
}
