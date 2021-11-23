//
//  SafariWebExtensionHandler.swift
//  Shared (Extension)
//
//  Created by Viktor Radulov on 22.11.2021.
//

import SafariServices
import os.log

let SFExtensionMessageKey = "message"

class TestService: NSObject, TestServiceProtocol {
    func publishToAllClients(string: String) {
        
    }
    
    func uppercase(string: String, reply: (String) -> ()) {
        reply(string.uppercased())
    }
}

class ServiceDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: TestServiceProtocol.self)//[NSXPCInterface interfaceWithProtocol:@protocol(TestServiceProtocol)];
//        TestService *exportedObject = [TestService new];
        newConnection.exportedObject = TestService()
        newConnection.resume()
        
//        [newConnection resume];
        return true
    }
}

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    
    private static var connection: NSXPCConnection?
    
    private static func initializeConnection() {
        let connection = NSXPCConnection(serviceName: "com.yourCompany.uBlock-Origin.Extension.service")
        connection.remoteObjectInterface = NSXPCInterface(with: TestServiceProtocol.self)
        connection.invalidationHandler = {
            SafariWebExtensionHandler.connection = nil
            NSLog("kuBlock: Connection invalidated")
        }
        connection.resume()
        
        SafariWebExtensionHandler.connection = connection
    }
    
    public static var viewController: ExtensionPopupViewController {
        let viewController = ExtensionPopupViewController()
        
        return viewController
    }

    func beginRequest(with context: NSExtensionContext) {
        let item = context.inputItems[0] as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey]
        NSLog("kuBlock: Received message from browser: " + (message as! [String: String]).values.first!)
        if (SafariWebExtensionHandler.connection == nil) {
            SafariWebExtensionHandler.initializeConnection()
        }
        
        (SafariWebExtensionHandler.connection?.synchronousRemoteObjectProxyWithErrorHandler({ error in
            NSLog( "kuBlock: Connection error " + error.localizedDescription)
        }) as? TestServiceProtocol)?.publishToAllClients(string: (message as! [String: String]).values.first!)

        let response = NSExtensionItem()
        response.userInfo = [ SFExtensionMessageKey: [ "Response to": message ] ]

//        context.completeRequest(returningItems: [response], completionHandler: nil)
        context.completeRequest(returningItems: nil, completionHandler: nil)
    }
}

//extension SafariWebExtensionHandler: SFSafariExtensionHandling {
//    func popoverViewController() -> SFSafariExtensionViewController {
//        SafariWebExtensionHandler.viewController
//    }
//}
