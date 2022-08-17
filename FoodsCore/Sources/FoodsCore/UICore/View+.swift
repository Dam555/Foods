//
//  View+.swift
//  
//
//  Created by Damjan on 16.08.2022.
//

import Foundation
import SwiftUI

extension View {

    public func flow() -> NavigationView<Self> {
        NavigationView {
            self
        }
    }
}
