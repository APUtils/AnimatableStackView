//
//  ViewModel.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation

// TODO: Documentation
protocol AnimatableStackView_ViewModel: Identifiable {
    associatedtype ViewClass = AnimatableStackView_View.Type
    static var viewClass: ViewClass { get }
}
