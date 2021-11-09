//
//  UIView+Utils.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/22/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

extension UIView {
    
    var isVisible: Bool { !isHidden && alpha >= 0.01 }
    
    /// Preserve view's size using autoresizing mask during layout.
    func layoutSubviewsOnly() {
        guard !subviews.isEmpty else { return }
        
        let activeOuterConstraints = getOuterConstraints().filter { $0.isActive }
        
        // Disable outer constraints to prevent broken constraints during layout
        NSLayoutConstraint.deactivate(activeOuterConstraints)
        
        if translatesAutoresizingMaskIntoConstraints {
            layoutSubviews()
        } else {
            // Fix view position and size during layout using autoresize mask
            translatesAutoresizingMaskIntoConstraints = true
            layoutSubviews()
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Restore outer constraints
        NSLayoutConstraint.activate(activeOuterConstraints)
    }
    
    /// Get all constraints to `self` from outer view hierarchy.
    func getOuterConstraints() -> [NSLayoutConstraint] {
        superviews
            .flatMap { $0.constraints(to: self) }
            .sorted { $0.priority > $1.priority }
    }
    
    /// Returns contraints to a `view` that source view owns.
    /// - Parameter view: A view to use for a check.
    func constraints(to view: UIView) -> [NSLayoutConstraint] {
        constraints.filter { $0.firstItem === view || $0.secondItem === view }
    }
    
#if compiler(>=5)
    /// All view superviews to the top most
    var superviews: DropFirstSequence<UnfoldSequence<UIView, (UIView?, Bool)>> {
        return sequence(first: self, next: { $0.superview }).dropFirst(1)
    }
#else
    /// All view superviews to the top most
    var superviews: AnySequence<UIView> {
        return sequence(first: self, next: { $0.superview }).dropFirst(1)
    }
#endif
}
