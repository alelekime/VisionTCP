//
//  TCPClientTerminal.swift
//  VisionTCP
//
//  Created by Alessandra Souza da Silva on 03/02/25.
//

import Foundation
import Network

/// A simple TCP client that connects to a server, sends messages,
/// listens for responses, and supports quitting with 'q'.
class TCPClientTerminal {
    var connection: NWConnection? // Client connection to the server
    var isRunning = true // Flag to control the client execution
    
    /// Initializes the client and attempts to connect to the server.
    /// - Parameters:
    ///   - host: The IP address or hostname of the server.
    ///   - port: The TCP port on which the server is listening.
    init(host: String, port: UInt16) {
        connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!, using: .tcp)
        
        // Monitor the connection state
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ Connected to the server")
                print("\n✉️ Type message (or 'q' to quit): ", terminator: "")
                self.listenForMessages() // Start listening for server messages
                self.startUserInputLoop() // Start accepting user input
            case .failed(let error):
                print("❌ Connection failed: \(error)")
                self.connection?.cancel()
            default:
                break
            }
        }
        
        connection?.start(queue: .global()) // Start the connection in a background queue
    }
    
    /// Continuously waits for user input from the terminal.
    /// Allows the client to send messages to the server or quit by typing 'q'.
    private func startUserInputLoop() {
        DispatchQueue.global().async {
            while self.isRunning {
                if let input = readLine(), !input.isEmpty {
                    if input.lowercased() == "q" { // If user types 'q', disconnect
                        self.quitClient()
                        break
                    }
                    self.sendMessage(input) // Send message to server
                    print("\n✉️ Type message (or 'q' to quit): ", terminator: "")
                }
            }
        }
    }
    
    /// Sends a message to the server.
    /// - Parameter message: The message to send.
    private func sendMessage(_ message: String) {
        let data = message.data(using: .utf8)!
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("❌ Send error: \(error)")
            }
        })
    }
    
    /// Listens for messages from the server.
    /// Displays received messages and continues listening.
    private func listenForMessages() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                print("\n📩 Server says: \(message)")
                print("\n✉️ Type message (or 'q' to quit): ", terminator: "")
            }
            if isComplete {
                self.quitClient() // Disconnect if the server closes the connection
            } else if error == nil {
                self.listenForMessages() // Continue listening for messages
            }
        }
    }
    
    /// Gracefully disconnects from the server and exits the client.
    private func quitClient() {
        print("\n🛑 Disconnecting from server...")
        isRunning = false
        connection?.cancel() // Close the connection
        exit(0) // Terminate the program
    }
}

// Connect to the server
let client = TCPClientTerminal(host: "localhost", port: 8080)
RunLoop.main.run() // Keep the program running
