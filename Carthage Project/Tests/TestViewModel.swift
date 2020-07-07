//
//  TestViewModel.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

@testable import AnimatableStackView

struct TestViewModel {
    let backgroundColor: UIColor
}

// ******************************* MARK: - AnimatableStackView_ViewModel

extension TestViewModel: AnimatableStackView_ViewModel {
    var animatableStackViewClass: AnimatableStackView_Subview.Type {
        return TestView.self
    }
    
    var id: String {
        return backgroundColor.description
    }
}
