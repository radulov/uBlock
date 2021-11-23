//
//  TestServiceProtocol.swift
//  uBlock Origin
//
//  Created by Viktor Radulov on 23.11.2021.
//

import Foundation

@objc public protocol TestServiceProtocol {
    func publishToAllClients(string: String)
}

@objc public protocol TestClientProtocol {
    func receiveMessage(string: String)
}
