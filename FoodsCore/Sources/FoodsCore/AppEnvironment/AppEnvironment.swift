//
//  AppEnvironment.swift
//  
//
//  Created by Damjan on 15.08.2022.
//

import Foundation

public class AppEnvironment: AppConfiguration {

    public static let `default`: AppEnvironment = {
        // Determine current app environment.
        // For example by reading user defaults key containig current environment name
        // that is shared with another (configurator) app which sets it.
        // `UserDefaults(suiteName: app_groups_suite_name)`
        return .staging
    }()

    private static let staging = AppEnvironment(
        environmentName: "staging",
        apiBaseUrl: URL(string: "https://uih0b7slze.execute-api.us-east-1.amazonaws.com/dev/")!
    )

    private static let integration = AppEnvironment(
        environmentName: "integration",
        apiBaseUrl: URL(string: "https://uih0b7slze.execute-api.us-east-1.amazonaws.com/int/")!
    )

    private static let production = AppEnvironment(
        environmentName: "production",
        apiBaseUrl: URL(string: "https://uih0b7slze.execute-api.us-east-1.amazonaws.com/prod/")!
    )

    public let environmentName: String
    public let apiBaseUrl: URL

    private init(environmentName: String, apiBaseUrl: URL) {
        self.environmentName = environmentName
        self.apiBaseUrl = apiBaseUrl
    }
}
