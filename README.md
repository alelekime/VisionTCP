# TCP Server-Client Communication in Swift

This project provides two implementations of a TCP server-client communication system using Swift's `Network` framework.

## 📂 Folder Structure

```
/VisionTCP
│── /Terminal
│   ├── TCPClientTerminal.swift
│   ├── TCPServerTerminal.swift
│
│── /TerminalJSON
│   ├── ClientJSON.swift
│   ├── ServerJSON.swift
│
│── README.md
```

---

## 📌 Project Overview

### **1️⃣ Terminal (Basic TCP Communication)**
This implementation supports **basic message exchange** over TCP using raw text.

- **TCPClientTerminal.swift**:  
  - Connects to a TCP server.
  - Allows users to type messages manually.
  - Receives and displays responses from the server.
  
- **TCPServerTerminal.swift**:  
  - Listens for incoming TCP connections.
  - Receives text-based messages and echoes them back.
  - Supports multiple clients.

### **2️⃣ TerminalJSON (Advanced JSON Communication)**
This implementation extends the **basic TCP model** by handling **structured JSON data**.

- **ClientJSON.swift**:
  - Connects to a TCP server and sends **structured JSON messages**.
  - Automatically generates test cases with valid and invalid JSON structures.
  - Simulates real-world scenarios by sending bulk messages.
  - Defines the `UserData` struct, used for serialization and deserialization.
  - Includes mock data generation for testing different cases.

- **ServerJSON.swift**:
  - Receives and **validates JSON** sent by clients.
  - Logs and handles **malformed, incomplete, or incorrect data**.
  - Responds to clients with success/error messages.
  - Defines the `UserData` struct, used for serialization and deserialization.

---

## 🚀 Setup & Usage

### **1️⃣ Running the Basic Terminal Version**

#### **Start the Server:**
```sh
cd Terminal
swift TCPServerTerminal.swift
```

#### **Start the Client:**
```sh
cd Terminal
swift TCPClientTerminal.swift
```

#### **Send Messages:**  
Type a message in the client terminal and press Enter. The server will echo the message.

---

### **2️⃣ Running the JSON Version**

#### **Start the JSON Server:**
```sh
cd TerminalJSON
swift ServerJSON.swift
```

#### **Start the JSON Client:**
```sh
cd TerminalJSON
swift ClientJSON.swift
```

#### **Expected Behavior:**
- The client sends **mock JSON objects** (valid & invalid).
- The server **validates, logs, and responds** accordingly.

---

## 🛠️ Troubleshooting

### **Client Fails to Connect**
1. Ensure the **server is running first** before starting the client.
2. Try changing `"127.0.0.1"` to `"localhost"` in `ClientJSON.swift`.
3. Check if another process is using **port 8080**:
   ```sh
   lsof -i :8080
   ```
   If a process is using the port, kill it:
   ```sh
   kill -9 <PID>
   ```
   Then restart the server.

### **Handling Network Issues**
- If testing **on two different machines**, find the **server's local IP**:
  ```sh
  ifconfig | grep "inet "
  ```
- Replace `"localhost"` in `ClientJSON.swift` with the **server's IP**.

---

## 📄 License
This project is open-source and free to use. Modify it as needed!

---

## 🤝 Contributing
Feel free to submit issues or PRs to improve the project! 🚀
