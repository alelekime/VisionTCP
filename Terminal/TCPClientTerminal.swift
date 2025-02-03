//
//  TCPClientTerminal.swift
//  VisionTCP
//
//  Created by Alessandra Souza da Silva on 03/02/25.
//

import Foundation
import Network

class TCPClientTerminal {
    var connection: NWConnection?
    
    init(host: String, port: UInt16) {
        connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!, using: .tcp)
        
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ Connected to the server")
                self.listenForMessages()
                self.startUserInputLoop()
            case .failed(let error):
                print("❌ Connection failed: \(error)")
            default:
                break
            }
        }
        
        connection?.start(queue: .global())
    }
    
    private func startUserInputLoop() {
        DispatchQueue.global().async {
            while true {
                print("✉️ Type message: ", terminator: "")
                if let input = readLine(), !input.isEmpty {
                    self.sendMessage(input)
                }
            }
        }
    }
    
    private func sendMessage(_ message: String) {
        let data = message.data(using: .utf8)!
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("❌ Send error: \(error)")
            }
        })
    }
    
    private func listenForMessages() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                print("\n📩 Server Response: \(message)")
            }
            if isComplete {
                self.connection?.cancel()
            } else if error == nil {
                self.listenForMessages()
            }
        }
    }
}

//let client = TCPClientTerminal(host: "localhost", port: 8080)
//RunLoop.main.run()
