//
//  AnimatableStackView.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit

// TODO: Documentation
public final class AnimatableStackView<View: AnimatableStackView_View, ViewModel>: UIStackView where View == ViewModel.ViewClass, View.ViewModel == ViewModel {
    
    // ******************************* MARK: - Private Properties
    
    private var views: [View] = []
    
    // ******************************* MARK: - Configuration
    
    public func configure(viewModels: [ViewModel]) {
        //// 1. Iterate over all viewModels and find:
        // - New views
        // - Deleted views
        // - Updated views
        var allNewViews: [View] = []
        var viewsToInsert: [View] = []
        var viewsToDelete: [View] = []
        var viewsToUpdate: [View] = []
        viewModels.forEach { viewModel in
            let view: View
            if let existingView = views.first(where: { $0.id == viewModel.id }) {
                // Update
                view = existingView
                viewsToUpdate.append(view)
            } else {
                // New
                let viewModelType = type(of: viewModel)
                let viewClass = viewModelType.viewClass
                view = viewClass.create(viewModel: viewModel)
                viewsToInsert.append(view)
            }
            
            allNewViews.append(view)
        }
        
        // Delete
        viewsToDelete = views
        viewsToDelete.removeAll(where: allNewViews.contains)
        
        //// 2. Insert new views collapsed at proper positions depending on old views layout.
        viewsToInsert.forEach { view in
            let originY: CGFloat
            if views.isEmpty {
                originY = 0
            } else if let index = allNewViews.firstIndex(of: view) {
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
        
        //// 3. Hide deleted views and remove them from arranged subviews after animation is done.
        // Note: Async is unsafe and can be improved later with additional checks if needed.
        viewsToDelete.forEach { $0.isHidden = true }
        
        let animationDuration = UIView.inheritedAnimationDuration
        let delayTime: DispatchTime = .now() + animationDuration
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            viewsToDelete.forEach(self.removeSubview)
        }
        
        //// 4. Update existing views
        viewsToUpdate.forEach { view in
            guard let viewModel = viewModels.first(where: { $0.id == view.id }) else { return }
            view.configure(viewModel: viewModel)
        }
        
        clear()
        
        // Keep deleting views as arranged subviews until they are dismissed.
        var allNewViewsWithDeletedViews = allNewViews
        viewsToDelete.forEach { view in
            var previousIndex = views.firstIndex(where: { $0.id == view.id }) ?? 0
            previousIndex = min(allNewViewsWithDeletedViews.endIndex, previousIndex)
            allNewViewsWithDeletedViews.insert(view, at: previousIndex)
        }
        
        allNewViewsWithDeletedViews.forEach(addArrangedSubview)
        views = allNewViews
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
