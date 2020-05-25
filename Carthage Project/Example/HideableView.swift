//
//  HideableView.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 5/25/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import AnimatableStackView
import UIKit

final class HideableView: UIView, AnimatableStackView_Subview {
    
    static func create(viewModel: Any) -> Self {
        let view = Self()
        view.configure(viewModel: viewModel)
        
        return view
    }
    
    private var viewModel: HideableViewModel!
    
    var id: String { viewModel.id }
    
    func configure(viewModel: Any) {
        guard let viewModel = viewModel as? HideableViewModel else { return }
        self.viewModel = viewModel
        
        backgroundColor = viewModel.color
        isHidden = viewModel.isHidden
        alpha = viewModel.isHidden ? 0 : 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 320, height: 50)
    }
}
