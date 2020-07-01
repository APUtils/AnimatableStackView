//
//  ViewsPool.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/1/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import UIKit

final class ViewsPool {
    
    private var views: [AnimatableStackView.Subview] = []
    
    func add(_ views: [AnimatableStackView.Subview]) {
        self.views.append(contentsOf: views)
    }
    
    func get(viewModel: AnimatableStackView.ViewModel) -> AnimatableStackView.Subview {
        if let existingViewIndex = views.firstIndex(where: { type(of: $0) == viewModel.viewClass }) {
            let existingView = views.remove(at: existingViewIndex)
            UIView.performWithoutAnimation {
                existingView.configure(viewModel: viewModel)
            }
            return existingView
            
        } else {
            var view: AnimatableStackView.Subview!
            UIView.performWithoutAnimation {
                view = viewModel.viewClass.create(viewModel: viewModel)
            }
            return view
        }
    }
}
