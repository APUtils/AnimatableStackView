//
//  HideableViewModel.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 5/25/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import AnimatableStackView
import Foundation

final class HideableViewModel: AnimatableStackView_ViewModel {
    
    let viewClass: AnimatableStackView_Subview.Type = HideableView.self
    let color: UIColor = UIColor.random
    let id: String = UUID().uuidString
    var isHidden: Bool = true
}
