//
//  CreatableWithViewModel.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation

// TODO: Documentation
public protocol CreatableWithViewModel: ConfigurableWithViewModel {
    static func create(viewModel: Any) -> Self
}
