//
//  CreatableWithViewModel.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation

/// Objects conforming to that protocol are able to be created and then configured with view model.
public protocol CreatableWithViewModel: ConfigurableWithViewModel {
    static func create(viewModel: Any) -> Self
}
