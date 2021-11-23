//
//  AppDelegate.swift
//  uBlock Origin Agent
//
//  Created by Viktor Radulov on 23.11.2021.
//

import Cocoa

@objc
class ConnectionDelegate: NSObject, NSXPCListenerDelegate, TestServiceProtocol {
    var connections = [NSXPCConnection]()
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        NSLog("kuBlock: agent received connection attempt")
        newConnection.exportedInterface = NSXPCInterface(with: TestServiceProtocol.self)
        newConnection.exportedObject = self
        
        newConnection.remoteObjectInterface = NSXPCInterface(with: TestClientProtocol.self)
        
        connections.append(newConnection)
        newConnection.invalidationHandler = {
            self.connections.removeAll {
                $0 == newConnection
            }
        }
        
        newConnection.resume()
        
        return true
    }
    
    func publishToAllClients(string: String) {
        NSLog("kuBlock: agent received: " + string)
        connections.forEach { connection in
            ((connection.synchronousRemoteObjectProxyWithErrorHandler { error in
                NSLog("kuBlock: agent connection error " + error.localizedDescription)
            }) as? TestClientProtocol)?.receiveMessage(string: string)
        }
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow!
    
    var connectionDelegate = ConnectionDelegate()
    var listener: NSXPCListener?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DispatchQueue.global().async {
            NSLog("kuBlock: agent started connection with " + Bundle.main.bundleIdentifier!)
            let listener = NSXPCListener(machServiceName: Bundle.main.bundleIdentifier!)
            listener.delegate = self.connectionDelegate
            
            listener.resume()
            
            self.listener = listener
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }

    

}

