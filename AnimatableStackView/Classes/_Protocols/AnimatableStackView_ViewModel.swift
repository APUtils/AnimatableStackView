//
//  ViewModel.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation

// TODO: Documentation
public protocol AnimatableStackView_ViewModel: Identifiable {
    static var viewClass: AnimatableStackView_View.Type { get }
}

public extension AnimatableStackView {
    // TODO: Documentation
    typealias ViewModel = AnimatableStackView_ViewModel
}
