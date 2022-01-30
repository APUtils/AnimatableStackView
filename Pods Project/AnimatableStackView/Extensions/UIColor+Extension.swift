//
//  UIColor+Extension.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 5/25/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import UIKit

extension UIColor {
    static var random: UIColor {
        let colors: [UIColor] = [.blue, .red, .green, .gray, .darkGray, .cyan, .yellow, .magenta, .orange, .purple, .brown]
        return colors.randomElement()!
    }
}
