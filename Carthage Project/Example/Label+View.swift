//
//  Label+View.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import AnimatableStackView


private var c_viewModelAssociationKey = 0
extension UILabel: AnimatableStackView_Subview, AnimatableView_Subview {
    
    private var _viewModel: String? {
        get {
            return objc_getAssociatedObject(self, &c_viewModelAssociationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &c_viewModelAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var viewModel: Any? {
        _viewModel
    }
    
    public func configure(viewModel: Any) {
        _viewModel = viewModel as? String
        text = viewModel as? String
    }
    
    public static func create(viewModel: Any) -> Self {
        let label = self.init()
        label.translatesAutoresizingMaskIntoConstraints = false
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
    public var animatableStackViewClass: AnimatableStackView_Subview.Type {
        return UILabel.self
    }
    
    public var id: String {
        return self
    }
}

extension String: AnimatableView_ViewModel {
    
    public func copy() -> String {
        self
    }
    
    public var animatableViewClass: AnimatableView_Subview.Type {
        return UILabel.self
    }
    
    public func hasChanges(from viewModel: AnimatableView_ViewModel) -> Bool {
        if let string = viewModel as? String {
            return self != string
        } else {
            return true
        }
    }
}
