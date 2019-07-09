//
//  View.swift
//  AnimatableStackView
//
//  Created by Anton Plebanovich on 7/9/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit

// TODO: Documentation
protocol AnimatableStackView_View: CreatableWithViewModel, Identifiable where Self: UIView, ViewModel: AnimatableStackView_ViewModel {}
