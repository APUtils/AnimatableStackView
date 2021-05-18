//
//  Utils.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

@testable import Example
import Nimble
import Nimble_Snapshots
import Quick
import UIKit

typealias SimpleClosure = () -> Void

enum Utils {
    
    /// Default Window size to use for UI checking unit tests
    static let defaultWindowSize = CGSize(width: 375, height: 667)
    
    /// Resizes view using the screen width and checks its layout inside `it` statement using `expect` call.
    /// - parameter resizeableScreenWidthView: A view with height to be layouted.
    /// - parameter sideInset: Left and right inset to the screen side.
    /// - parameter beforeLayout: Actions to execute before layout. They are performed inside `it` closure so additional checks are possible inside it.
    static func shouldHaveProperLayout(resizeableScreenWidthView: @escaping @autoclosure () -> UIView,
                                       sideInset: CGFloat = 0,
                                       beforeLayout: SimpleClosure? = nil,
                                       file: Quick.FileString = #file,
                                       line: UInt = #line) {
        
        it("should have proper layout") {
            let resizeableScreenWidthView = resizeableScreenWidthView()
            assert(!(resizeableScreenWidthView is UITableViewCell), "Please use shouldHaveProperLayout(resizeableCell:) instead")
            assert(!(resizeableScreenWidthView is UICollectionViewCell), "Please use shouldHaveProperLayout(resizeableCell:) instead")
            
            resizeableScreenWidthView.translatesAutoresizingMaskIntoConstraints = false
            resizeableScreenWidthView.widthAnchor.constraint(equalToConstant: defaultWindowSize.width - sideInset * 2).isActive = true
            
            beforeLayout?()
            resizeableScreenWidthView.layoutIfNeededInWindow()
            
            expect(file: file, line: line, resizeableScreenWidthView).to(haveValidSnapshot())
        }
    }
}

// ******************************* MARK: - Snapshots Recording

/// Set to true to update snapshots
private let recordSnapshots = false

func haveValidSnapshot(named name: String? = nil, identifier: String? = nil, usesDrawRect: Bool = false, tolerance: CGFloat? = nil) -> Predicate<Snapshotable> {
    if recordSnapshots {
        return recordSnapshot(named: name, identifier: identifier, usesDrawRect: usesDrawRect)
    } else {
        return Nimble_Snapshots.haveValidSnapshot(named: name, identifier: identifier, usesDrawRect: usesDrawRect, tolerance: tolerance)
    }
}

// ******************************* MARK: - Private Extensions

private extension UIView {
    
    func layoutIfNeededInWindow() {
        let window = UIWindow(frame: .init(origin: .zero, size: Utils.defaultWindowSize))
        AppDelegate.shared.window = window
        
        window.addSubview(self)
        leftAnchor.constraint(equalTo: window.leftAnchor).isActive = true
        topAnchor.constraint(equalTo: window.topAnchor).isActive = true
        
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        
        window.rootViewController = nil
        window.isHidden = true
        
        // https://stackoverflow.com/a/59988501/4124265
        if #available(iOS 13.0, *) {
            window.windowScene = nil
        }
    }
}
