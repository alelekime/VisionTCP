//
//  ClientJSON.swift
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

/// Generates different variations of mock `UserData` objects for testing.
func generateMockUserData() -> [Data] {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted // For better readability

    let validUser1 = UserData(
        id: 1001,
        name: "Alice Johnson",
        age: 28,
        email: "alice@example.com",
        isActive: true,
        lastLogin: Date(),
        scores: [95.4, 87.2, 92.1],
        metadata: ["role": "admin", "location": "NYC"]
    )

    let validUser2 = UserData(
        id: 2002,
        name: "Bob Smith",
        age: 35,
        email: "bob@example.com",
        isActive: false,
        lastLogin: Date(),
        scores: [85.0, 79.5, 90.2],
        metadata: ["role": "user", "location": "LA"]
    )

    /// ❌ **Malformed JSON** (Invalid format - Missing closing brace)
    let malformedJSON = """
    {
        "id": 3003,
        "name": "Charlie Brown",
        "age": 42,
        "email": "charlie@example.com",
        "isActive": true,
        "lastLogin": "2024-02-03T12:30:00Z",
        "scores": [88.8, 91.0],
        "metadata": { "role": "guest", "location": "Chicago"
    """.data(using: .utf8)!

    /// ❌ **Incomplete JSON** (Missing required fields)
    let incompleteJSON = """
    {
        "id": 4004,
        "name": "David Miller"
    }
    """.data(using: .utf8)!

    /// ❌ **Wrong data types** (Age as String instead of Int)
    let wrongDataTypesJSON = """
    {
        "id": 5005,
        "name": "Eva Green",
        "age": "Thirty",
        "email": "eva@example.com",
        "isActive": true,
        "lastLogin": "2024-02-03T15:45:00Z",
        "scores": [92.3, 88.1],
        "metadata": { "role": "moderator", "location": "San Francisco" }
    }
    """.data(using: .utf8)!

    /// ✅ **Bulk JSON Messages** (Multiple valid objects in an array)
    let bulkUsers = [
        validUser1, validUser2
    ]

    var jsonMocks: [Data] = []

    do {
        // ✅ Valid JSON cases
        jsonMocks.append(try encoder.encode(validUser1))
        jsonMocks.append(try encoder.encode(validUser2))

        // ✅ Bulk JSON case
        jsonMocks.append(try encoder.encode(bulkUsers))

    } catch {
        print("❌ JSON Encoding error: \(error)")
    }

    // ❌ Invalid cases
    jsonMocks.append(malformedJSON)
    jsonMocks.append(incompleteJSON)
    jsonMocks.append(wrongDataTypesJSON)

    return jsonMocks
}

class ClientJSON {
    var connection: NWConnection?
    var isRunning = true

    init(host: String, port: UInt16) {
        connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!, using: .tcp)

        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ Connected to the server")
                self.sendMockData()
                self.listenForResponse()
            case .failed(let error):
                print("❌ Connection failed: \(error)")
                self.connection?.cancel()
            default:
                break
            }
        }

        connection?.start(queue: .global())
    }

    private func sendMockData() {
        let mockMessages = generateMockUserData() // Get all test cases

        for jsonData in mockMessages {
            connection?.send(content: jsonData, completion: .contentProcessed { error in
                if let error = error {
                    print("❌ Send error: \(error)")
                } else {
                    print("📤 Sent mock data to server!")
                }
            })

            sleep(1) // Simulate delay between messages
        }
    }

    private func listenForResponse() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, _, error in
            if let data = data, let response = String(data: data, encoding: .utf8) {
                print("\n📩 Server Response: \(response)")
            }
            if error == nil {
                self.listenForResponse()
            }
        }
    }
}

// Connect to the server
let client = ClientJSON(host: "localhost", port: 8080)
RunLoop.main.run()
