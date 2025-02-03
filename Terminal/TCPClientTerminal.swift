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
    var isRunning = true
    
    init(host: String, port: UInt16) {
        connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!, using: .tcp)
        
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ Connected to the server")
                print("\n✉️ Type message (or 'q' to quit): ", terminator: "")
                self.listenForMessages()
                self.startUserInputLoop()
            case .failed(let error):
                print("❌ Connection failed: \(error)")
                self.connection?.cancel()
            default:
                break
            }
        }
        
        connection?.start(queue: .global())
    }
    
    private func startUserInputLoop() {
        DispatchQueue.global().async {
            while self.isRunning {
                if let input = readLine(), !input.isEmpty {
                    if input.lowercased() == "q" {
                        self.quitClient()
                        break
                    }
                    self.sendMessage(input)
                    print("\n✉️ Type message (or 'q' to quit): ", terminator: "")
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
                print("\n📩 Server says: \(message)")
                print("\n✉️ Type message (or 'q' to quit): ", terminator: "")
            }
            if isComplete {
                self.quitClient()
            } else if error == nil {
                self.listenForMessages()
            }
        }
    }
    
    private func quitClient() {
        print("\n🛑 Disconnecting from server...")
        isRunning = false
        connection?.cancel()
        exit(0)
    }
}


// Connect to the server
let client = TCPClientTerminal(host: "localhost", port: 8080)
RunLoop.main.run()
