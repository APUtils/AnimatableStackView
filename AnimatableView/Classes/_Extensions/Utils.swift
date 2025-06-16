//
//  Utils.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/6/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import Foundation

final class Utils {
    
    /// Executes a closure in the main queue after requested seconds asynchronously. Uses GCD.
    /// - parameters:
    ///   - delay: number of seconds to delay
    ///   - closure: the closure to be executed
    static func _performInMain(_ delay: TimeInterval = 0, closure: @escaping () -> Void) {
        if delay <= 0, Thread.isMainThread {
            closure()
            
        } else {
            let delayTime: DispatchTime = .now() + delay
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                closure()
            }
        }
    }
}
