//
//  AppDelegate.swift
//  macOS (App)
//
//  Created by Viktor Radulov on 22.11.2021.
//

import Cocoa

class ExportedObject: NSObject, TestClientProtocol {
    func receiveMessage(string: String) {
        print("message from extension: " + string)
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var connectionToService: NSXPCConnection?
    var exportedObject = ExportedObject()

    func applicationDidFinishLaunching(_ notification: Notification) {
        AgentLoader.loadAgent()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 5.0) {
            self.testConnection();
        }
    }
    
    func testConnection() {
        
        connectionToService = NSXPCConnection(serviceName: AgentLoader.bundleIdentifier!)

        connectionToService?.remoteObjectInterface = NSXPCInterface(with: TestServiceProtocol.self)

        connectionToService?.exportedInterface = NSXPCInterface(with: TestClientProtocol.self)
        connectionToService?.exportedObject = self.exportedObject

        connectionToService?.invalidationHandler = {
            NSLog("kuBlock: main app to agent connection invalidated")
        }
        connectionToService?.resume()
        
//        (connectionToService?.remoteObjectProxyWithErrorHandler({ error in
//            print(error)
//        }) as? TestServiceProtocol)?.publishToAllClients(string: "HUI")

    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    

}
