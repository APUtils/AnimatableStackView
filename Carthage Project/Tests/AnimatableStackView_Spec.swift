// https://github.com/Quick/Quick

@testable import AnimatableStackView
import Nimble
import Nimble_Snapshots
import Quick

class AnimatableStackView_Spec: QuickSpec {
    override func spec() {
        describe("AnimatableStackView") {
            context("When instantiated from code") {
                let sv = AnimatableStackView(frame: .zero)
                sv.axis = .vertical
                Utils.showInWindow(innerHeightView: sv)
                
                let redVM = TestViewModel(backgroundColor: .red)
                let greenVM = TestViewModel(backgroundColor: .green)
                let blueVM = TestViewModel(backgroundColor: .blue)
                let brownVM = TestViewModel(backgroundColor: .brown)
                let orangeVM = TestViewModel(backgroundColor: .orange)
                
                context("and configure with red-green-blue view models") {
                    beforeEach { sv.configure(viewModels: [redVM, greenVM, blueVM]) }
                    it("should have red-green-blue snaphot") { expect(sv).to(haveValidSnapshot()) }
                    
                    context("and reconfigured with green-blue-red view models") {
                        beforeEach { sv.configure(viewModels: [greenVM, blueVM, redVM]) }
                        it("should have green-blue-red snaphot") { expect(sv).to(haveValidSnapshot()) }
                    }
                    
                    context("and reconfigured with green-brown view models") {
                        beforeEach { sv.configure(viewModels: [greenVM, brownVM]) }
                        it("should have green-brown snaphot") { expect(sv).to(haveValidSnapshot()) }
                    }
                    
                    // Blue views have same ID so only last one will be added as view because of views reuse.
                    context("and reconfigured with blue-blue-blue-orange-blue view models") {
                        beforeEach { sv.configure(viewModels: [blueVM, blueVM, blueVM, orangeVM, blueVM]) }
                        it("should have orange-blue snaphot") { expect(sv).to(haveValidSnapshot()) }
                    }
                }
            }
        }
    }
}
