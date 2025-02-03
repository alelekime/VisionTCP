//
//  TCPServerTerminal.swift
//  VisionTCP
//
//  Created by Alessandra Souza da Silva on 03/02/25.
//

import Foundation
import Network

/// A simple TCP server that listens for client connections,
/// allows bidirectional communication, and supports multiple clients.
class TCPServerTerminal {
    var listener: NWListener? // The server listener to accept connections
    var clients: [NWConnection] = [] // Array to store connected clients
    var isRunning = true // Flag to control the server execution

    /// Initializes the server and starts listening for incoming client connections.
    init() {
        do {
            listener = try NWListener(using: .tcp, on: 8080) // Initialize the TCP listener on port 8080
        } catch {
            print("❌ Failed to create listener: \(error)")
            return
        }
        
        // Handle new client connections
        listener?.newConnectionHandler = { connection in
            self.handleNewConnection(connection)
        }
        
        // Start the listener in a background thread
        listener?.start(queue: .global())
        print("✅ Server started on port 8080")
        print("✉️ Type message to send to all clients (or 'q' to quit): ", terminator: "")

        // Start listening for user input in the background
        DispatchQueue.global().async {
            self.waitForUserInput()
        }
    }

    /// Handles a new client connection.
    /// - Parameter connection: The new client connection.
    private func handleNewConnection(_ connection: NWConnection) {
        print("\n🔗 New client connected!") // Notify that a client has connected
        clients.append(connection) // Store the new client connection

        // Monitor the connection state
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("✅ Client connection is ready")
                self.receiveMessage(connection) // Start receiving messages from the client
            case .failed(let error):
                print("❌ Client connection failed: \(error)")
                self.removeClient(connection) // Remove disconnected client
                connection.cancel()
            default:
                break
            }
        }

        connection.start(queue: .global()) // Start the connection in a background queue
    }

    /// Receives a message from a connected client.
    /// - Parameter connection: The client connection that sent the message.
    private func receiveMessage(_ connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                print("\n📩 Received from client: \(message)")
                self.sendMessage("Echo: \(message)", to: connection) // Echo the message back to the client
                print("\n✉️ Type message to send to all clients (or 'q' to quit): ", terminator: "")
            }
            if isComplete {
                self.removeClient(connection) // Remove client if connection is closed
                connection.cancel()
            } else if error == nil {
                self.receiveMessage(connection) // Continue listening for messages
            }
        }
    }

    /// Sends a message to a specific client.
    /// - Parameters:
    ///   - message: The message to send.
    ///   - connection: The client connection.
    private func sendMessage(_ message: String, to connection: NWConnection) {
        let data = message.data(using: .utf8)!
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("❌ Send error: \(error)")
            }
        })
    }

    /// Continuously waits for user input from the terminal.
    /// Allows the server to send messages to all clients or quit by typing 'q'.
    private func waitForUserInput() {
        while isRunning {
            if let input = readLine(), !input.isEmpty {
                if input.lowercased() == "q" { // If user types 'q', stop the server
                    stopServer()
                    break
                }
                broadcastMessage(input) // Send message to all clients
                print("\n✉️ Type message to send to all clients (or 'q' to quit): ", terminator: "")
            }
        }
    }

    /// Sends a message to all connected clients.
    /// - Parameter message: The message to broadcast.
    private func broadcastMessage(_ message: String) {
        print("\n📤 Sending to all clients: \(message)")
        for client in clients {
            sendMessage(message, to: client)
        }
    }

    /// Removes a disconnected client from the list of active connections.
    /// - Parameter connection: The client connection to remove.
    private func removeClient(_ connection: NWConnection) {
        clients.removeAll { $0 === connection }
    }

    /// Gracefully stops the server, closing all client connections.
    private func stopServer() {
        print("\n🛑 Stopping server...")
        listener?.cancel() // Stop accepting new connections
        isRunning = false
        for client in clients {
            client.cancel() // Disconnect all clients
        }
        exit(0) // Terminate the program
    }
}

// Start the server
let server = TCPServerTerminal()
RunLoop.main.run() // Keep the program running
