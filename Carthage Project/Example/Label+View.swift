//
//  Label+View.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import AnimatableStackView


extension UILabel: AnimatableStackView_View {
    public func configure(viewModel: Any) {
        text = viewModel as? String
    }
    
    public static func create(viewModel: Any) -> Self {
        let label = self.init()
        label.contentMode = .top
        label.backgroundColor = .random
        label.configure(viewModel: viewModel)
        
        return label
    }
    
    public var id: String {
        return text ?? ""
    }
    
    public typealias ViewModel = String
    
    
}

extension String: AnimatableStackView_ViewModel {
    public static var viewClass: AnimatableStackView_View.Type = UILabel.self
    
    public var id: String {
        return self
    }
}


private extension UIColor {
    static var random: UIColor {
        let colors: [UIColor] = [.blue, .red, .green, .gray, .darkGray, .cyan, .yellow, .magenta, .orange, .purple, .brown]
        return colors.randomElement()!
    }
}
