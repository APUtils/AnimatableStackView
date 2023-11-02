//
//  HideableViewModel.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 5/25/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import AnimatableView
import Foundation

final class HideableViewModel: AnimatableView_ViewModel {
    
    let animatableViewClass: AnimatableView_Subview.Type = HideableView.self
    var color: UIColor = UIColor.random
    var id: String = UUID().uuidString
    var isHidden: Bool = true
    
    func copy() -> Self {
        let copy = Self()
        copy.id = id
        copy.isHidden = isHidden
        
        return copy
    }
    
    func hasChanges(from viewModel: AnimatableView_ViewModel) -> Bool {
        guard let viewModel = viewModel as? HideableViewModel else { return true }
        return color != viewModel.color
            || isHidden != viewModel.isHidden
    }
}
