//
//  LaunchctlRegistry.swift
//  uBlock Origin (macOS)
//
//  Created by Viktor Radulov on 23.11.2021.
//

import Foundation

struct LaunchctlRegistry: Codable {
    
    enum ProcessType: String, Codable {
        case background = "Background"
        case standard = "Standard"
        case adaptive = "Adaptive"
        case interactive = "Interactive"
    }
    
    enum SessionType: String, Codable {
        case background = "Background"
        case aqua = "Aqua"
        case loginWindow = "LoginWindow"
    }
    
    static let agentsPath = "/Library/LaunchAgents/"
    static let daemonsPath = "/Library/LaunchDaemons/"
    
    var disabled: Bool?
    var keepAlive = true
    var sessionType: SessionType?
    let label: String
    let program: String
    var processType: ProcessType?
    var machServices: [String: Bool]?
    var runAtLoad: Bool?
    var arguments: [String]?
    
    var defaultPlistName: String {
        return label + ".plist"
    }
    
    private enum CodingKeys: String, CodingKey {
        var rawValue: String {
            switch self {
            case .disabled: return LAUNCH_JOBKEY_DISABLED
            case .keepAlive: return LAUNCH_JOBKEY_KEEPALIVE
            case .sessionType: return LAUNCH_JOBKEY_LIMITLOADTOSESSIONTYPE
            case .label: return LAUNCH_JOBKEY_LABEL
            case .program: return LAUNCH_JOBKEY_PROGRAM
            case .processType: return LAUNCH_JOBKEY_PROCESSTYPE
            case .machServices: return LAUNCH_JOBKEY_MACHSERVICES
            case .runAtLoad: return LAUNCH_JOBKEY_RUNATLOAD
            case .arguments: return LAUNCH_JOBKEY_PROGRAMARGUMENTS
            }
        }
        
        case disabled
        case keepAlive
        case sessionType
        case label
        case program
        case processType
        case machServices
        case runAtLoad
        case arguments
    }
    
    init?(bundle: Bundle) {
        guard let bundleIdentifier = bundle.bundleIdentifier,
              let executablePath = bundle.executablePath else { return nil }
        self.init(label: bundleIdentifier, program: executablePath)
    }
    
    init(label: String, program: String) {
        self.label = label
        self.program = program
    }
}
