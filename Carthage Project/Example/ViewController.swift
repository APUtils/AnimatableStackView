//
//  ViewController.swift
//  AnimatableStackView-Example
//
//  Created by Anton Plebanovich on 4/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import APExtensions
import UIKit
import AnimatableStackView

final class ViewController: UIViewController {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var stackViewContainer: UIView!
    
    // ******************************* MARK: - Private Properties
    
    private let stackView: AnimatableStackView<UILabel, String>! = .init()
    private let vms1 = ["1", "2", "3"]
    private let vms2 = ["3", "2", "1", "4", "5"]
    
    // ******************************* MARK: - Initialization and Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStackView()
    }
    
    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        stackViewContainer.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: stackViewContainer.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: stackViewContainer.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: stackViewContainer.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: stackViewContainer.bottomAnchor)
            ])
    }
    
    // ******************************* MARK: - Actions
    
    @IBAction private func onAnimateTap(_ sender: Any) {
        g.animate(2) {
            self.stackView.configure(viewModels: self.vms1)
            self.view.layoutIfNeeded()
        }
        
        g.asyncMain(2) {
            g.animate(2) {
                self.stackView.configure(viewModels: self.vms2)
                self.view.layoutIfNeeded()
            }
        }
    }
}

