//
//  TestView.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

@testable import AnimatableStackView

final class TestView: UIView {
    
    // ******************************* MARK: - Properties
    
    private var vm: TestViewModel!
    
    // ******************************* MARK: - Initialization and Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    // ******************************* MARK: - UIView Overrides
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: 50)
    }
}

// ******************************* MARK: - AnimatableStackView_Subview

extension TestView: AnimatableStackView_Subview {
    static func create(viewModel: Any) -> Self {
        let view = self.init(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        view.configure(viewModel: viewModel)
        return view
    }
    
    var id: String {
        return vm.id
    }
    
    func configure(viewModel: Any) {
        guard let vm = viewModel as? TestViewModel else { return }
        self.vm = vm
        backgroundColor = vm.backgroundColor
    }
}
