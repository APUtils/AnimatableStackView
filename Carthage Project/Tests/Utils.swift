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
import UIKit

enum Utils {
    
    /// Default Window size to use for UI checking unit tests
    static let defaultWindowRect = CGRect(x: 0, y: 0, width: 375, height: 667)
    
    /// Shows VC in a default window.
    /// This method must be used for UI unit tests.
    static func showInWindow(vc: UIViewController) {
        let window = UIWindow(frame: defaultWindowRect)
        AppDelegate.shared.window = window
        window.rootViewController = vc
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
    }
    
    /// Shows view with inner height in a default window.
    /// This method must be used for UI unit tests.
    /// - parameter innerHeightView: View that has specific inner height that shouldn't be broken.
    static func showInWindow(innerHeightView: UIView) {
        let vc = UIViewController()
        vc.view.addSubview(innerHeightView)
        innerHeightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            innerHeightView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            innerHeightView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            innerHeightView.topAnchor.constraint(equalTo: vc.view.topAnchor)
            ])
        showInWindow(vc: vc)
    }
    
    /// Shows resizeable view in a default window.
    /// This method must be used for UI unit tests.
    /// - parameter resizeableView: View that may be resized to any size and properly layout for that.
    static func showInWindow(resizeableView: UIView) {
        let vc = UIViewController()
        vc.view = resizeableView
        showInWindow(vc: vc)
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
