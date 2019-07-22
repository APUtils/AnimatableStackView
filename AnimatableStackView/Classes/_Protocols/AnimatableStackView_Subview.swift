//
//  Subview.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit

/// Subview that can be created with view model and has an ID.
public protocol AnimatableStackView_Subview: UIView, CreatableWithViewModel, Identifiable {}

public extension AnimatableStackView {
    /// Subview that can be created with view model and has an ID.
    typealias Subview = AnimatableStackView_Subview
}
