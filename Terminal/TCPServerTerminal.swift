//
//  TCPServerTerminal.swift
//  VisionTCP
//
//  Created by Alessandra Souza da Silva on 03/02/25.
//

import Foundation
import Network

class TCPServerTerminal {
    var listener: NWListener?
    var clients: [NWConnection] = []
    var isRunning = true
    
    init() {
        do {
            listener = try NWListener(using: .tcp, on: port)
        } catch {
            print("❌ Failed to create listener: \(error)")
            return
        }
        
        listener?.newConnectionHandler = { connection in
            self.handleNewConnection(connection)
        }
        
        listener?.start(queue: .global())
        print("✅ Server started on port \(port)")
        print("✉️ Type message to send to all clients (or 'q' to quit): ", terminator: "")
        
        // Start listening for user input
        DispatchQueue.global().async {
            self.waitForUserInput()
        }
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        print("\n🔗 New client connected!")
        clients.append(connection)
        
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("✅ Client connection is ready")
                self.receiveMessage(connection)
            case .failed(let error):
                print("❌ Client connection failed: \(error)")
                self.removeClient(connection)
                connection.cancel()
            default:
                break
            }
        }
        
        connection.start(queue: .global())
    }
    
    private func receiveMessage(_ connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                print("\n📩 Received from client: \(message)")
                self.sendMessage("Echo: \(message)", to: connection)
                print("\n✉️ Type message to send to all clients (or 'q' to quit): ", terminator: "")
            }
            if isComplete {
                self.removeClient(connection)
                connection.cancel()
            } else if error == nil {
                self.receiveMessage(connection)
            }
        }
    }
    
    private func sendMessage(_ message: String, to connection: NWConnection) {
        let data = message.data(using: .utf8)!
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("❌ Send error: \(error)")
            }
        })
    }
    
    private func waitForUserInput() {
        while isRunning {
            if let input = readLine(), !input.isEmpty {
                if input.lowercased() == "q" {
                    stopServer()
                    break
                }
                broadcastMessage(input)
                print("\n✉️ Type message to send to all clients (or 'q' to quit): ", terminator: "")
            }
        }
    }
    
    private func broadcastMessage(_ message: String) {
        print("\n📤 Sending to all clients: \(message)")
        for client in clients {
            sendMessage(message, to: client)
        }
    }
    
    private func removeClient(_ connection: NWConnection) {
        clients.removeAll { $0 === connection }
    }
    
    private func stopServer() {
        print("\n🛑 Stopping server...")
        listener?.cancel()
        isRunning = false
        for client in clients {
            client.cancel()
        }
        exit(0)
    }
}

// Start the server
let server = TCPServerTerminal()
RunLoop.main.run()
