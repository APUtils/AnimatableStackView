//
//  AnimatableView.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/2/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import Foundation
import RoutableLogger
import UIKit

/// Subview that can be created with view model and has an ID.
public protocol AnimatableView_Subview: UIView, CreatableWithViewModel, Identifiable {
    var animatableViewModel: Any? { get }
}

/// View model that has ID and view class to which it belong.
public protocol AnimatableView_ViewModel: Identifiable {
    var animatableViewClass: AnimatableView_Subview.Type { get }
    
    // Optional method that may be used to prevent updates if the view model doesn't have any changes compared to an another.
    func hasChanges(from viewModel: Any?) -> Bool
}

public extension AnimatableView_ViewModel {
    
    /// Creates view configures with `self`.
    func createConfiguredView() -> AnimatableView_Subview {
        animatableViewClass.create(viewModel: self)
    }
}

public extension AnimatableView_ViewModel {
    func hasChanges(from viewModel: Any?) -> Bool { true }
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
    /// - parameter viewModels: View models that will be used to configure a new state.
    ///
    /// Views will be reused or created whenever needed and properly attached so animation will be smooth.
    ///
    /// - warning: View model and view (after configuration) IDs should match for the reuse logic to work. Basicaly, you should just return view model's ID after your view was configured with it.
    open func update(viewModels: [ViewModel]) {
        
        func beforeReuse(view: UIView) {
            // Restore original alpha
            if let originalAlpha = view.originalAlpha {
                view.alpha = originalAlpha
                view.originalAlpha = nil
            }
        }
        
        func afterReuse(view: UIView, previousView: UIView, hasChanges: Bool, isAnimating: Bool) {
            // Ignore invisible views
            guard view.isVisible else { return }
            
            // Prepare for animation if needed
            if isAnimating {
                view.performNonAnimatedForInvisible {
                    let y = previousView === self ? 0 : previousView.frame.maxY
                    if hasChanges {
                        view.layoutHeight(y: y, width: bounds.width)
                        view.layoutSubviewsOnly()
                    } else {
                        view.frame.origin.y = y
                    }
                    
                    // Sned to back so new views will slide from under existing ones.
                    sendSubviewToBack(view)
                }
            }
        }
        
        // Reusing views with the same ID first
        let existingReusableViews: [String: Subview] = viewModels.dictionaryMap { viewModel in
            if let view = viewsPool.getExistingNonConfiguredView(viewModel: viewModel) {
                return (viewModel.id, view)
            } else {
                return nil
            }
        }
        
        let isAnimating = UIView.isAnimating
        let previousViews = visibleViews
        var newViews: [Subview] = []
        var previousView: UIView = self
        var constraints: [NSLayoutConstraint] = []
        
        viewModels.forEach { viewModel in
            var view: Subview!
            if let existingView = visibleViews.first(where: { $0.id == viewModel.id }) {
                // Update
                view = existingView
                if viewModel.hasChanges(from: existingView.animatableViewModel) {
                    view.configure(viewModel: viewModel)
                    checkID(subview: view, viewModel: viewModel)
                }
                
            } else if let existingReusableView = existingReusableViews[viewModel.id] {
                // Reuse existing
                existingReusableView.performNonAnimatedForInvisible {
                    beforeReuse(view: existingReusableView)
                    if viewModel.hasChanges(from: existingReusableView.animatableViewModel as? AnimatableView.ViewModel) {
                        existingReusableView.configure(viewModel: viewModel)
                        afterReuse(view: existingReusableView, previousView: previousView, hasChanges: true, isAnimating: isAnimating)
                        checkID(subview: existingReusableView, viewModel: viewModel)
                        
                    } else {
                        afterReuse(view: existingReusableView, previousView: previousView, hasChanges: false, isAnimating: isAnimating)
                    }
                }
                
                view = existingReusableView
                view.animateFadeInIfNeeded()
                
            } else {
                
                // Reuse or creation
                view = viewsPool.getConfiguredView(viewModel: viewModel,
                                                   width: bounds.width,
                                                   onCreation: { view in
                    
                    afterReuse(view: view, previousView: previousView, hasChanges: true, isAnimating: isAnimating)
                    
                    // Insert at 0 so new views will slide from under existing ones.
                    insertSubview(view, at: 0)
                    
                    constraints.append(view.leadingAnchor.constraint(equalTo: leadingAnchor))
                    constraints.append(view.trailingAnchor.constraint(equalTo: trailingAnchor))
                    
                }, beforeReuse: beforeReuse, afterReuse: { afterReuse(view: $0, previousView: previousView, hasChanges: $1, isAnimating: isAnimating) })
                
                view.animateFadeInIfNeeded()
            }
            
            // Return an invisible view to the views pool
            guard view.isVisible else {
                viewsPool.add(view)
                return
            }
            
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
    
    /// Find view that corresponds to passed ID.
    open func getView(id: String) -> Subview? {
        return subviews
            .compactMap { $0 as? Subview }
            .first { $0.id == id }
    }
    
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
    
    func add(_ view: AnimatableView.Subview) {
        self.views.append(view)
    }
    
    func add(_ views: [AnimatableView.Subview]) {
        self.views.append(contentsOf: views)
    }
    
    func getExistingNonConfiguredView(viewModel: AnimatableView.ViewModel) -> AnimatableView.Subview? {
        if let existingViewIndex = views.firstIndex(where: { $0.id == viewModel.id }) {
            /// Found reusable view with the same ID. Checking if it requires reconfiguration.
            let existingView = views.remove(at: existingViewIndex)
            return existingView
            
        } else {
            return nil
        }
    }
    
    func getConfiguredView(viewModel: AnimatableView.ViewModel,
                           width: CGFloat,
                           onCreation: ViewClosure = { _ in },
                           beforeReuse: ViewClosure = { _ in },
                           afterReuse: HasChangesClosure = { _, _ in }) -> AnimatableView.Subview {
        
        if let existingViewIndex = views.firstIndex(where: { $0.id == viewModel.id }) {
            /// Found reusable view with the same ID. Checking if it requires reconfiguration.
            let existingView = views.remove(at: existingViewIndex)
            existingView.performNonAnimatedForInvisible {
                beforeReuse(existingView)
                if viewModel.hasChanges(from: existingView.animatableViewModel as? AnimatableView.ViewModel) {
                    existingView.configure(viewModel: viewModel)
                    afterReuse(existingView, true)
                    checkID(subview: existingView, viewModel: viewModel)
                    
                } else {
                    afterReuse(existingView, false)
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
                checkID(subview: existingView, viewModel: viewModel)
            }
            
            return existingView
            
        } else {
            /// Create new configured view and return.
            var view: AnimatableView.Subview!
            UIView.performWithoutAnimation {
                view = viewModel.createConfiguredView()
                
                // View will be managed by constraints so make sure mask is disabled
                if view.translatesAutoresizingMaskIntoConstraints {
                    RoutableLogger.logInfo("Autoresizing mask will be disabled for a view: \(view.description)")
                    view.translatesAutoresizingMaskIntoConstraints = false
                }
                
                // We need to layout because view might be of a wrong size after creation and configuration
                view.layoutHeight(width: width)
                view.layoutSubviewsOnly()
                
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

extension CALayer {
    
    func removeAllAnimationsRecursively() {
        removeAllAnimations()
        sublayers?.forEach { $0.removeAllAnimationsRecursively() }
    }
}

private func checkID(subview: AnimatableView_Subview, viewModel: AnimatableView_ViewModel) {
    if subview.id != viewModel.id {
        RoutableLogger.logError("View should have the same ID as view model after configuration", data: ["subviewID": subview.id, "viewModelID": viewModel.id, "subview": subview, "viewModel": viewModel])
    }
}
