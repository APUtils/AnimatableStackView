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
    associatedtype ViewClass where ViewClass: AnimatableStackView_View
    static var viewClass: ViewClass.Type { get }
}
