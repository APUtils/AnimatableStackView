//
//  View.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit

// TODO: Documentation
public protocol AnimatableStackView_View: CreatableWithViewModel, Identifiable where Self: UIView {}

public extension AnimatableStackView {
    // TODO: Documentation
    typealias View = AnimatableStackView_View
}
