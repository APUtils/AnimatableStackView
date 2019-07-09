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
final class AnimatableStackView<View: AnimatableStackView_View, ViewModel: AnimatableStackView_ViewModel>: UIStackView {
    
    // ******************************* MARK: - Private Properties
    
    private var views: [View] = []
    
    // ******************************* MARK: - Configuration
    
    func configure(viewModels: [ViewModel]) {
        // 1. Remove arranged subviews
        // 2. Iterate over all vms
        // 3. Try to find view with same ID, configure it and add it to views array
        // 4. If not found create new view and add it to views array and as arranged subview
        // 5. Replace old views with new ones
    }
}
