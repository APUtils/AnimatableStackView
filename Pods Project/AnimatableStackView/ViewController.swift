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
    
    @IBOutlet private var containerView: AnimatableView!
    
    // ******************************* MARK: - Private Properties
    
    private let vms1: [String] = ["1", "2", "3"]
    private let vms2: [String] = ["3", "2", "1", "4", "5"]
    private let vms3: [String] = ["3", "0", "-1", "2", "1", "4", "5"]
    private let vms4: [String] = []
    
    private var hideVMs: [HideableViewModel] = [HideableViewModel(),HideableViewModel(),HideableViewModel(),HideableViewModel()]
    
    // ******************************* MARK: - Initialization and Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.update(viewModels: [])
    }
    
    // ******************************* MARK: - Actions
    
    @IBAction private func onAnimateTap(_ sender: Any) {
        g.animate(2) {
            self.containerView.update(viewModels: self.vms1)
            self.view.layoutIfNeeded()
        }
        
        g.asyncMain(2) {
            g.animate(2) {
                self.containerView.update(viewModels: self.vms2)
                self.view.layoutIfNeeded()
            }
            
            g.asyncMain(2) {
                g.animate(2) {
                    self.containerView.update(viewModels: self.vms3)
                    self.view.layoutIfNeeded()
                }
                
                g.asyncMain(2) {
                    g.animate(2) {
                        self.containerView.update(viewModels: self.vms2)
                        self.view.layoutIfNeeded()
                    }
                    
                    g.asyncMain(2) {
                        g.animate(2) {
                            self.containerView.update(viewModels: self.vms1)
                            self.view.layoutIfNeeded()
                        }
                        
                        g.asyncMain(2) {
                            g.animate(2) {
                                self.containerView.update(viewModels: self.vms4)
                                self.view.layoutIfNeeded()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction private func onAnimate2Tap(_ sender: Any) {
        g.animate(2) {
            self.hideVMs.modifyForEach { $1.isHidden.toggle() }
            self.containerView.update(viewModels: self.hideVMs)
            self.view.layoutIfNeeded()
        }
    }
}
