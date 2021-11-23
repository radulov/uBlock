//
//  SafariWebExtensionHandler.swift
//  Shared (Extension)
//
//  Created by Viktor Radulov on 22.11.2021.
//

import SafariServices
import os.log

let SFExtensionMessageKey = "message"

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling, TestClientProtocol {
    
    private var connection: NSXPCConnection?
    
    private func initializeConnection() {
        let connection = NSXPCConnection(serviceName: "com.yourCompany.uBlock-Origin.Extension.service")
        connection.remoteObjectInterface = NSXPCInterface(with: TestServiceProtocol.self)
        connection.invalidationHandler = {
            self.connection = nil
            NSLog("kuBlock: Connection invalidated")
        }
        connection.exportedInterface = NSXPCInterface(with: TestClientProtocol.self)
        connection.exportedObject = self
        connection.resume()
        
        self.connection = connection
    }
    
    public static var viewController: ExtensionPopupViewController {
        let viewController = ExtensionPopupViewController()
        
        return viewController
    }

    func beginRequest(with context: NSExtensionContext) {
        let item = context.inputItems[0] as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey]
        if let messageDict = message as? [String: String],
           let stringMessage = messageDict[SFExtensionMessageKey] {
            NSLog("kuBlock: Received message from browser: " + stringMessage)
            if (self.connection == nil) {
                self.initializeConnection()
            }
            
            (self.connection?.remoteObjectProxyWithErrorHandler({ error in
                NSLog( "kuBlock: Connection error " + error.localizedDescription)
            }) as? TestServiceProtocol)?.publishToAllClients(string: stringMessage)
        }

        let response = NSExtensionItem()
        response.userInfo = [ SFExtensionMessageKey: [ "Response to": message ] ]

//        context.completeRequest(returningItems: [response], completionHandler: nil)
        context.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    func receiveMessage(string: String) {
        NSLog("kuBlock: extension received message from app: " + string)
    }
}
