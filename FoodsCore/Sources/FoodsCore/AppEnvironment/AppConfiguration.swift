//
//  AppConfiguration.swift
//  
//
//  Created by Damjan on 15.08.2022.
//

import Foundation

public protocol AppConfiguration {

    var environmentName: String { get }
    var apiBaseUrl: URL { get }
}
