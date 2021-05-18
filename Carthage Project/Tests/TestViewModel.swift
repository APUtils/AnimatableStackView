//
//  TestViewModel.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

@testable import AnimatableStackView

struct TestViewModel {
    let id = UUID().uuidString
    let backgroundColor: UIColor
    
    func clone() -> TestViewModel {
        TestViewModel(backgroundColor: backgroundColor)
    }
}

// ******************************* MARK: - AnimatableStackView_ViewModel

extension TestViewModel: AnimatableStackView_ViewModel {
    var animatableStackViewClass: AnimatableStackView_Subview.Type {
        return TestView.self
    }
}

// ******************************* MARK: - AnimatableView_ViewModel

extension TestViewModel: AnimatableView_ViewModel {
    
    var animatableViewClass: AnimatableView_Subview.Type { TestView.self }
    
    func copy() -> TestViewModel { self }
    
    func hasChanges(from viewModel: Any?) -> Bool {
        guard let viewModel = viewModel as? TestViewModel else { return true }
        return backgroundColor != viewModel.backgroundColor
    }
}
