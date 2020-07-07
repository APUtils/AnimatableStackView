//
//  UIView+Utils.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/22/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

extension UIView {
    
    var isVisible: Bool { !isHidden && alpha >= 0.01 }
    
    /// Preserve view's size using autoresizing mask during layout.
    func layoutSubviewsOnly() {
        let originalParam = translatesAutoresizingMaskIntoConstraints
        translatesAutoresizingMaskIntoConstraints = true
        layoutIfNeeded()
        translatesAutoresizingMaskIntoConstraints = originalParam
    }
}
