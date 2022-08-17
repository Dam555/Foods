//
//  UIApplication+.swift
//  
//
//  Created by Damjan on 15.08.2022.
//

import Foundation
import UIKit

extension UIApplication {

    public static var isRunningUnitTests: Bool {
        NSClassFromString("XCTest") != nil
    }
}
