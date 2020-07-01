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
    @IBOutlet private var containerView: UIView!
    
    // ******************************* MARK: - Private Properties
    
    private let vms1: [String] = ["1", "2", "3"]
    private let vms2: [String] = ["3", "2", "1", "4", "5"]
    private let vms3: [String] = ["3", "0", "-1", "2", "1", "4", "5"]
    private let vms4: [String] = []
    
    private var hideVMs: [HideableViewModel] = [HideableViewModel(),HideableViewModel(),HideableViewModel(),HideableViewModel()]
    
    // ******************************* MARK: - Initialization and Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        let vms1000 = stride(from: 0, to: 1000, by: 1).map { "\($0)" }
        let vms500 = stride(from: 0, to: 500, by: 1).map { "\($0)" }
        let date1 = Date()
        self.stackView.update(viewModels: vms1000, postLayout: false)
        view.layoutIfNeeded()
        print("********1 %f", Date().timeIntervalSince(date1))
        
        let date2 = Date()
        self.stackView.update(viewModels: vms500, postLayout: false)
        view.layoutIfNeeded()
        print("********2 %f", Date().timeIntervalSince(date2))
        
        let date3 = Date()
        var previousView: UIView!
        var constraints: [NSLayoutConstraint] = []
        vms1000.forEach { string in
            let view = UILabel.create(viewModel: string)
            containerView.addSubview(view)
            
            if let previousView = previousView {
                constraints.append(view.topAnchor.constraint(equalTo: previousView.bottomAnchor))
            }
            
            constraints.append(view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor))
            constraints.append(view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor))
            
            if string == vms1000.first {
                constraints.append(view.topAnchor.constraint(equalTo: containerView.topAnchor))
            } else if string == vms1000.last {
                constraints.append(view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor))
            }
            
            previousView = view
        }
        NSLayoutConstraint.activate(constraints)
        view.layoutIfNeeded()
        print("********3 %f", Date().timeIntervalSince(date3))
        
        let date4 = Date()
        containerView.subviews[500..<1000].forEach { $0.removeFromSuperview() }
        
        previousView = nil
        constraints = []
        containerView.subviews[0..<500].enumerated().forEach { index, view in
            view.removeFromSuperview()
            containerView.addSubview(view)
            
            if let previousView = previousView {
                constraints.append(view.topAnchor.constraint(equalTo: previousView.bottomAnchor))
            }
            
            constraints.append(view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor))
            constraints.append(view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor))
            
            if index == 0 {
                constraints.append(view.topAnchor.constraint(equalTo: containerView.topAnchor))
            } else if index == 499 {
                constraints.append(view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor))
            }
            
            previousView = view
        }
        NSLayoutConstraint.activate(constraints)
        
        view.layoutIfNeeded()
        print("********4 %f", Date().timeIntervalSince(date4))
        
        self.stackView.update(viewModels: self.hideVMs)
    }
    
    // ******************************* MARK: - Actions
    
    @IBAction private func onAnimateTap(_ sender: Any) {
        UIView.animate(withDuration: 2) {
            self.stackView.update(viewModels: self.vms1)
            self.view.layoutIfNeeded()
        }
        
        g.asyncMain(2) {
            UIView.animate(withDuration: 2) {
                self.stackView.update(viewModels: self.vms2)
                self.view.layoutIfNeeded()
            }
            
            g.asyncMain(2) {
                UIView.animate(withDuration: 2) {
                    self.stackView.update(viewModels: self.vms3)
                    self.view.layoutIfNeeded()
                }
                
                g.asyncMain(2) {
                    UIView.animate(withDuration: 2) {
                        self.stackView.update(viewModels: self.vms4)
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    @IBAction private func onAnimate2Tap(_ sender: Any) {
        UIView.animate(withDuration: 2) {
            self.hideVMs.modifyForEach { $1.isHidden.toggle() }
            self.stackView.update(viewModels: self.hideVMs)
            self.view.layoutIfNeeded()
        }
    }
}
