//
//  ServerJSON.swift
//  
//
//  Created by Alessandra Souza da Silva on 03/02/25.
//

import Foundation
import Network

/// Struct representing a complex data model for user information.
struct UserData: Codable {
    let id: Int
    let name: String
    let age: Int
    let email: String
    let isActive: Bool
    let lastLogin: Date
    let scores: [Double]
    let metadata: [String: String]
}


class ServerJSON {
    var listener: NWListener?
    var clients: [NWConnection] = []
    var isRunning = true

    init() {
        do {
            listener = try NWListener(using: .tcp, on: 8080)
        } catch {
            print("❌ Failed to create listener: \(error)")
            return
        }

        listener?.newConnectionHandler = { connection in
            self.handleNewConnection(connection)
        }

        listener?.start(queue: .global())
        print("✅ Server started on port 8080")
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
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { data, _, isComplete, error in
            if let data = data {
                self.processReceivedData(data, from: connection)
            }
            if isComplete {
                self.removeClient(connection)
                connection.cancel()
            } else if error == nil {
                self.receiveMessage(connection)
            }
        }
    }

    /// Processes received JSON data, validates it, and handles errors gracefully.
    private func processReceivedData(_ data: Data, from connection: NWConnection) {
        do {
            let userData = try JSONDecoder().decode(UserData.self, from: data)

            // ✅ Validate required fields
            if userData.id <= 0 || userData.name.isEmpty || userData.email.isEmpty {
                throw ValidationError.missingRequiredFields
            }

            // ✅ Log and print the received data
            print("\n📩 Received UserData from client:")
            print("ID: \(userData.id)")
            print("Name: \(userData.name)")
            print("Age: \(userData.age)")
            print("Email: \(userData.email)")
            print("Is Active: \(userData.isActive)")
            print("Last Login: \(userData.lastLogin)")
            print("Scores: \(userData.scores)")
            print("Metadata: \(userData.metadata)")

            self.sendResponse("✅ Data received successfully", to: connection)

        } catch let decodingError as DecodingError {
            print("❌ JSON Decoding error: \(decodingError)")
            self.sendResponse("❌ Invalid JSON format", to: connection)

        } catch ValidationError.missingRequiredFields {
            print("❌ Validation error: Missing required fields")
            self.sendResponse("❌ Missing required fields in JSON", to: connection)

        } catch {
            print("❌ Unknown error while processing data: \(error)")
            self.sendResponse("❌ Server error while processing data", to: connection)
        }
    }

    /// Sends a response message back to the client.
    private func sendResponse(_ message: String, to connection: NWConnection) {
        let data = message.data(using: .utf8)!
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("❌ Send error: \(error)")
            }
        })
    }

    private func removeClient(_ connection: NWConnection) {
        clients.removeAll { $0 === connection }
    }
}

/// Custom error type for validation failures
enum ValidationError: Error {
    case missingRequiredFields
}

// Start the server
let server = ServerJSON()
RunLoop.main.run()
