//
//  AnimatableStackView.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit

/// Subview that can be created with view model and has an ID.
public protocol AnimatableStackView_Subview: UIView, CreatableWithViewModel, Identifiable {}

/// View model that has ID and view class to which it belong.
public protocol AnimatableStackView_ViewModel: Identifiable {
    var animatableStackViewClass: AnimatableStackView_Subview.Type { get }
}

/// Ordinary stack view that supports animations.
/// Just perform changes using `update(viewModels:postLayout:)`
/// and then call `view.layoutIfNeeded()` inside animation block.
open class AnimatableStackView: UIStackView {
    
    /// View model that has ID and view class to which it belong.
    public typealias ViewModel = AnimatableStackView_ViewModel
    
    /// Subview that can be created with view model and has an ID.
    public typealias Subview = AnimatableStackView_Subview
    
    // ******************************* MARK: - Public Properties
    
    /// Array of `Views` that animatable view is currently displaying
    public private(set) var views: [Subview] = []
    private let viewsPool = ViewsPool()
    
    // ******************************* MARK: - Private Properties
    
    /// UIStackView must have at least one view to layout views horizontally correctly ¯\_(ツ)_/¯
    private lazy var zeroHeightView: UIView = {
        let zeroHeightView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: 0))
        zeroHeightView.backgroundColor = .clear
        zeroHeightView.translatesAutoresizingMaskIntoConstraints = false
        zeroHeightView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        zeroHeightView.accessibilityIdentifier = "Layout Fix View Do Not Remove"
        
        return zeroHeightView
    }()
    
    // ******************************* MARK: - Initialization and Setup
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        addArrangedSubview(zeroHeightView)
    }
    
    // ******************************* MARK: - Configuration
    
    /// Core method to update stack view's arranged subviews.
    /// May be called inside animation block.
    /// If called inside animation block `layoutIfNeeded()` should be called on base view,
    /// e.g. view controller's view for animations to work.
    /// - parameter viewModels: View models that will be used to configure a new state.
    /// - parameter postLayout: Post layout is required to update inner constraints so resizeable table view cells can update their heights but in some cases you may want to delay `layoutIfNeeded()` call. For example, if you have constraints outside of stack view and you want to animate everything together.
    /// Views will be reused or created whenever needed and properly attached so animation will be smooth.
    open func update(viewModels: [ViewModel], postLayout: Bool = true) {
        
        let animationDuration = UIView.inheritedAnimationDuration
        let initialOriginY = frame.origin.y
        
        //// 1. Iterate over all viewModels and find:
        // - New views
        // - Deleted views
        // - Updated views
        
        // All views for new `viewModels` (insert + update)
        var allNewViews: [Subview] = []
        
        var viewsToInsert: [Subview] = []
        var viewsToDelete: [Subview] = []
        var viewsToUpdate: [Subview] = []
        viewModels.forEach { viewModel in
            var view: Subview!
            if let existingView = views.first(where: { $0.id == viewModel.id }) {
                // Update
                view = existingView
                viewsToUpdate.append(view)
            } else {
                // Prevent animations during creation
                UIView.performWithoutAnimation {
                    view = viewsPool.get(viewModel: viewModel, beforeReuse: { $0.isHidden = false })
                }
                
                viewsToInsert.append(view)
            }
            
            allNewViews.append(view)
        }
        
        // Delete
        viewsToDelete = views
        viewsToDelete.removeAll { viewToDelete in allNewViews.contains { $0.id == viewToDelete.id } }
        
        //// 2. Insert new views collapsed at proper positions depending on old views layout.
        
        clear()
        
        viewsToInsert.forEach { view in
            let originY: CGFloat
            if views.isEmpty {
                originY = 0
            } else if let index = allNewViews.firstIndex(where: { $0.id == view.id }) {
                if index == 0 {
                    originY = 0
                } else {
                    // We take previous view and attaching to its end
                    originY = allNewViews[index - 1].frame.maxY
                }
            } else {
                originY = 0
            }
            
            // Preparing view and its subviews for animation.
            // View and its subviews should be able to handle zero height properly.
            if animationDuration > 0 {
                UIView.performWithoutAnimation {
                    view.frame = CGRect(x: 0, y: originY, width: bounds.size.width, height: 0)
                    view.layoutSubviewsOnly()
                    addSubview(view)
                }
            }
        }
        
        //// 3. Insert all views
        
        // Keep deleting views as arranged subviews until they are dismissed.
        var allNewViewsWithDeletedViews = allNewViews
        viewsToDelete.forEach { view in
            var previousIndex = views.firstIndex(where: { $0.id == view.id }) ?? 0
            previousIndex = min(allNewViewsWithDeletedViews.endIndex, previousIndex)
            allNewViewsWithDeletedViews.insert(view, at: previousIndex)
        }
        
        allNewViewsWithDeletedViews.forEach { view in
            // Fixing view's width. It might be wrong in a case stack view height is zero.
            if animationDuration > 0 {
                UIView.performWithoutAnimation {
                    view.frame.size.width = bounds.size.width
                    view.layoutSubviewsOnly()
                }
            }
            
            self.addArrangedSubview(view)
        }
        
        //// 4. Hide deleted views and remove them from arranged subviews after animation is done.
        viewsToDelete.forEach { $0.isHidden = true }
        
        // Note: Async is unsafe and can be improved later with additional checks if needed.
        Utils.performInMain(animationDuration) {
            viewsToDelete.forEach { self.removeSubview($0) }
            self.viewsPool.add(viewsToDelete)
        }
        
        //// 5. Update existing views
        viewsToUpdate.forEach { view in
            guard let viewModel = viewModels.first(where: { $0.id == view.id }) else { return }
            view.configure(viewModel: viewModel)
            checkID(subview: view, viewModel: viewModel)
        }
        
        views = allNewViews
        
        // During update some views isHidden property might get changed but stack view somehow delays
        // this update till the end of the animation closure. The bad thing is we might need to know
        // exact stack view and its elements positions during animation computation.
        // So to force layout we are removing and then adding back all views.
        clear()
        allNewViewsWithDeletedViews.forEach { addArrangedSubview($0) }
        
        // Force constraints layout to support height update inside cells
        if postLayout {
            layoutIfNeeded()
        }
        
        // Restore vertical position
        frame.origin.y = initialOriginY
    }
    
    // ******************************* MARK: - Other Public Methods
    
    /// Find view that corresponds to passed identity. E.g. you can pass view model and get view for that.
    open func getView(identity: Identifiable) -> Subview? {
        return views.first { $0.id == identity.id }
    }
    
    // ******************************* MARK: - Private Methods
    
    /// Properly removes arranged subview from stack view.
    /// - note: `removeArrangedSubview` call is required because it contains some clanup code.
    /// If it wasn't called and view was added back to stack view layout behavior will be upredictable.
    private func removeSubview(_ view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
        
        // Remove stack view's hide constraints.
        // In some cases they might not be removed ¯\_(ツ)_/¯
        NSLayoutConstraint.deactivate(
            view.constraints
                .filter { $0.identifier == "UISV-hiding" }
        )
    }
    
    /// Properly removes all arranged subviews from stack view.
    private func clear() {
        arrangedSubviews
            .filter { $0 != zeroHeightView }
            .forEach(removeSubview)
        
        // Update constraints so we won't have issues if we add the same views later.
        layoutIfNeeded()
    }
}

private final class ViewsPool {
    
    typealias Closure = (AnimatableStackView.Subview) -> Void
    
    // TODO: Can be improved by using dictionary but we need a performant way of converting `viewClass` to a hash.
    private var views: [AnimatableStackView.Subview] = []
    
    func add(_ views: [AnimatableStackView.Subview]) {
        self.views.append(contentsOf: views)
    }
    
    func get(viewModel: AnimatableStackView.ViewModel, onCreation: Closure = { _ in }, beforeReuse: Closure = { _ in }) -> AnimatableStackView.Subview {
        
        if let existingViewIndex = views.firstIndex(where: { type(of: $0) == viewModel.animatableStackViewClass }) {
            let existingView = views.remove(at: existingViewIndex)
            UIView.performWithoutAnimation {
                beforeReuse(existingView)
                existingView.configure(viewModel: viewModel)
                checkID(subview: existingView, viewModel: viewModel)
            }
            return existingView
            
        } else {
            var view: AnimatableStackView.Subview!
            UIView.performWithoutAnimation {
                view = viewModel.animatableStackViewClass.create(viewModel: viewModel)
                onCreation(view)
                checkID(subview: view, viewModel: viewModel)
            }
            return view
        }
    }
}

private func checkID(subview: AnimatableStackView_Subview, viewModel: AnimatableStackView_ViewModel) {
    if subview.id != viewModel.id {
        print("[AnimatableStackView] ERROR: View should have the same ID as view model after configuration. Please check. View ID '\(subview.id)' != view model ID '\(viewModel.id)'")
    }
}
