//
//  AnimatableStackView.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit

/// Ordinary stack view that supports animations.
/// Just perform changes using `configure(viewModels:)`
/// and then call `view.layoutIfNeeded()` inside animation block.
open class AnimatableStackView: UIStackView {
    
    // ******************************* MARK: - Private Properties
    
    /// Array of `Views` that stack view currently displaying.
    public private(set) var views: [Subview] = []
    
    // ******************************* MARK: - Configuration
    
    /// Core method to configure stack view's arranged subviews.
    /// Should be called inside animation block and `layoutIfNeeded()`
    /// should be called on base view, e.g. view controller's view
    /// for animations to work.
    /// - parameter viewModels: View models that will be used to configure a new state.
    /// Views will be reused or created whenever needed and properly attacked so animation will be smooth.
    open func configure(viewModels: [ViewModel]) {
        //// 1. Iterate over all viewModels and find:
        // - New views
        // - Deleted views
        // - Updated views
        var allNewViews: [Subview] = []
        var viewsToInsert: [Subview] = []
        var viewsToDelete: [Subview] = []
        var viewsToUpdate: [Subview] = []
        viewModels.forEach { viewModel in
            let view: Subview
            if let existingView = views.first(where: { $0.id == viewModel.id }) {
                // Update
                view = existingView
                viewsToUpdate.append(view)
            } else {
                // New
                let viewClass = viewModel.viewClass
                view = viewClass.create(viewModel: viewModel)
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
                let clampedIndex = min(views.endIndex - 1, index)
                originY = views[clampedIndex].frame.maxY
            } else {
                originY = 0
            }
            
            UIView.performWithoutAnimation {
                view.frame = CGRect(x: 0, y: originY, width: bounds.size.width, height: 0)
                
                // Layout subviews for a new view frame.
                // Preserve view's size using autoresizing mask during layout.
                // View and its subviews should be able to handle zero height properly.
                let originalParam = view.translatesAutoresizingMaskIntoConstraints
                view.translatesAutoresizingMaskIntoConstraints = true
                view.layoutIfNeeded()
                view.translatesAutoresizingMaskIntoConstraints = originalParam
                
                addSubview(view)
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
        
        allNewViewsWithDeletedViews.forEach { self.addArrangedSubview($0) }
        
        //// 4. Hide deleted views and remove them from arranged subviews after animation is done.
        // Note: Async is unsafe and can be improved later with additional checks if needed.
        viewsToDelete.forEach { $0.isHidden = true }
        
        let animationDuration = UIView.inheritedAnimationDuration
        let delayTime: DispatchTime = .now() + animationDuration
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            viewsToDelete.forEach { self.removeSubview($0) }
        }
        
        //// 5. Update existing views
        viewsToUpdate.forEach { view in
            guard let viewModel = viewModels.first(where: { $0.id == view.id }) else { return }
            view.configure(viewModel: viewModel)
        }
        
        views = allNewViews
        
        // Force constraints layout to support height update inside cells
        layoutIfNeeded()
    }
    
    // ******************************* MARK: - Public Methods
    
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
        arrangedSubviews.forEach(removeSubview)
    }
}
