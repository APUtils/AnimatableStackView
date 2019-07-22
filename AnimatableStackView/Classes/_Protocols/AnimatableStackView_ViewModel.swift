//
//  ViewModel.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation

/// View model that has ID and view class to which it belong.
public protocol AnimatableStackView_ViewModel: Identifiable {
    var viewClass: AnimatableStackView_Subview.Type { get }
}

public extension AnimatableStackView {
    /// View model that has ID and view class to which it belong.
    typealias ViewModel = AnimatableStackView_ViewModel
}
