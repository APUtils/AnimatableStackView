//
//  AnimatableView_Spec.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/7/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

@testable import AnimatableStackView
import Nimble
import Nimble_Snapshots
import Quick

class AnimatableView_Spec: QuickSpec {
    override func spec() {
        describe("AnimatableView") {
            context("when instantiated from code") {
                let av = AnimatableView(frame: .zero)
                
                let redVM = TestViewModel(backgroundColor: .red)
                let greenVM = TestViewModel(backgroundColor: .green)
                let blueVM = TestViewModel(backgroundColor: .blue)
                let brownVM = TestViewModel(backgroundColor: .brown)
                let orangeVM = TestViewModel(backgroundColor: .orange)
                
                context("and configure with red-green-blue view models") {
                    Utils.shouldHaveProperLayout(resizeableScreenWidthView: av, beforeLayout: {
                        av.update(viewModels: [redVM, greenVM, blueVM])
                    })
                    
                    context("and reconfigured with green-blue-red view models") {
                        Utils.shouldHaveProperLayout(resizeableScreenWidthView: av, beforeLayout: {
                            av.update(viewModels: [greenVM, blueVM, redVM])
                        })
                    }
                    
                    context("and reconfigured with green-brown view models") {
                        Utils.shouldHaveProperLayout(resizeableScreenWidthView: av, beforeLayout: {
                            av.update(viewModels: [greenVM, brownVM])
                        })
                    }
                    
                    // Blue views have same ID so only last one will be added as view because of views reuse.
                    context("and reconfigured with blue-blue-blue-orange-blue view models") {
                        Utils.shouldHaveProperLayout(resizeableScreenWidthView: av, beforeLayout: {
                            av.update(viewModels: [blueVM, blueVM.clone(), blueVM.clone(), orangeVM, blueVM.clone()])
                        })
                    }
                }
            }
        }
        
        it("should be at least 50% more performant than AnimatableStackView") {
            
            let percent = 0.5
            
            let hostView = UIView()
            
            let sv = AnimatableStackView(frame: .zero)
            sv.axis = .vertical
            hostView.addSubview(sv)
            sv.topAnchor.constraint(equalTo: hostView.topAnchor).isActive = true
            sv.leadingAnchor.constraint(equalTo: hostView.leadingAnchor).isActive = true
            
            let av = AnimatableView(frame: .zero)
            hostView.addSubview(av)
            av.topAnchor.constraint(equalTo: hostView.topAnchor).isActive = true
            av.leadingAnchor.constraint(equalTo: hostView.leadingAnchor).isActive = true
            
            hostView.layoutIfNeeded()
            
            let vms100 = stride(from: 0, to: 100, by: 1).map { "\($0)" }
            let vms50 = stride(from: 0, to: 50, by: 1).map { "\($0)" }
            
            let date1 = Date()
            sv.update(viewModels: vms100, postLayout: false)
            hostView.layoutIfNeeded()
            let executionTime1 = Date().timeIntervalSince(date1)
            
            let date2 = Date()
            sv.update(viewModels: [], postLayout: false)
            sv.update(viewModels: vms50, postLayout: false)
            hostView.layoutIfNeeded()
            let executionTime2 = Date().timeIntervalSince(date2)
            
            let date3 = Date()
            av.update(viewModels: vms100)
            hostView.layoutIfNeeded()
            let executionTime3 = Date().timeIntervalSince(date3)
            
            let date4 = Date()
            av.update(viewModels: [])
            av.update(viewModels: vms50)
            hostView.layoutIfNeeded()
            let executionTime4 = Date().timeIntervalSince(date4)
            
            expect(executionTime3).to(beLessThan(executionTime1 * percent))
            expect(executionTime4).to(beLessThan(executionTime2 * percent))
        }
    }
}
