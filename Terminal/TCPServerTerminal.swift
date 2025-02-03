//
//  TCPServerTerminal.swift
//  VisionTCP
//
//  Created by Alessandra Souza da Silva on 03/02/25.
//

import Foundation
import Network

class TCPServerTerminal {
    let port: NWEndpoint.Port = 8080
    var listener: NWListener?
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
        
        // Start listening for user input
        DispatchQueue.global().async {
            self.waitForQuitCommand()
        }
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        print("🔗 New client connected!")
        
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("✅ Client connection is ready")
                self.receiveMessage(connection)
            case .failed(let error):
                print("❌ Client connection failed: \(error)")
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
                print("📩 Received from client: \(message)")
                self.sendMessage("Echo: \(message)", connection: connection)
            }
            if isComplete {
                connection.cancel()
            } else if error == nil {
                self.receiveMessage(connection)
            }
        }
    }
    
    private func sendMessage(_ message: String, connection: NWConnection) {
        let data = message.data(using: .utf8)!
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("❌ Send error: \(error)")
            }
        })
    }
    
    /// Wait for user to type 'q' to quit the server
    private func waitForQuitCommand() {
        while isRunning {
            print("🛑 Type 'q' and press Enter to stop the server: ", terminator: "")
            if let input = readLine(), input.lowercased() == "q" {
                stopServer()
                break
            }
        }
    }
    
    /// Gracefully stop the server
    private func stopServer() {
        print("🛑 Stopping server...")
        listener?.cancel()
        isRunning = false
        exit(0)
    }
}

//let server = TCPServerTerminal()
//RunLoop.main.run()
