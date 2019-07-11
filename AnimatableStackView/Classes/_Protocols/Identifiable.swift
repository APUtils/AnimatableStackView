//
//  Identifiable.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation

/// Object that can be identified using ID.
public protocol Identifiable {
    var id: String { get }
}
