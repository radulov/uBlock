//
//  AgentLoader.swift
//  uBlock Origin (macOS)
//
//  Created by Viktor Radulov on 23.11.2021.
//

import Foundation

class AgentLoader {
    static let agentBundle: Bundle? = {
        let folderWithAgent = Bundle.main.bundleURL.path + "/Contents" + LaunchctlRegistry.agentsPath
        guard let folder = try? FileManager.default.contentsOfDirectory(atPath: folderWithAgent),
              let name = folder.first else { return nil }
        
        return Bundle(path: folderWithAgent + name)
    }()
    static let bundleIdentifier = agentBundle?.bundleIdentifier
    static let pathToLaunchPlist = NSHomeDirectory() + LaunchctlRegistry.agentsPath + bundleIdentifier! + ".plist"

    static func loadAgent() {
        guard let bundleIdentifier = bundleIdentifier,
              let agentBundle = agentBundle,
              var registry = LaunchctlRegistry(bundle: agentBundle) else {
            NSLog("Agent Loader could not find path to app.")
            
            return
        }
        
        registry.machServices = [bundleIdentifier: true]
        registry.disabled = false
        
        if FileManager.default.fileExists(atPath: pathToLaunchPlist) {
            Process.launchedProcess(launchPath: "/bin/launchctl", arguments: ["unload", pathToLaunchPlist]).waitUntilExit()
        }
        
        do {
            try? FileManager.default.createDirectory(atPath: NSHomeDirectory() + LaunchctlRegistry.agentsPath, withIntermediateDirectories: false, attributes: [:])
            try (try PropertyListEncoder().encode(registry)).write(to: URL(fileURLWithPath: pathToLaunchPlist))
            
            Process.launchedProcess(launchPath: "/bin/launchctl", arguments: ["load", pathToLaunchPlist])
        } catch let err {
            NSLog("Agent Loader failed with error: \(err)")
        }
    }
}
