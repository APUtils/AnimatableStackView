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
    
    @IBOutlet private weak var stackView: AnimatableStackView!
    
    // ******************************* MARK: - Private Properties
    
    private let vms1 = ["1", "2", "3"]
    private let vms2 = ["3", "2", "1", "4", "5"]
    
    // ******************************* MARK: - Initialization and Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // ******************************* MARK: - Actions
    
    @IBAction private func onAnimateTap(_ sender: Any) {
        UIView.animate(withDuration: 2) {
            self.stackView.configure(viewModels: self.vms1)
            self.view.layoutIfNeeded()
        }
        
        g.asyncMain(2) {
            UIView.animate(withDuration: 2) {
                self.stackView.configure(viewModels: self.vms2)
                self.view.layoutIfNeeded()
            }
        }
    }
}
