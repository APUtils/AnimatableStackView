//
//  View.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit

/// View that can be created with view model and has an ID.
public protocol AnimatableStackView_View: UIView, CreatableWithViewModel, Identifiable {}

public extension AnimatableStackView {
    /// View that can be created with view model and has an ID.
    typealias View = AnimatableStackView_View
}
