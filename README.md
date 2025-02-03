
# TCP Server-Client Communication in Swift

This project provides a simple TCP server-client implementation in Swift using Apple's `Network` framework. It allows sending and receiving messages entirely through the terminal.

## 📌 Features
- **TCP Server (`TCPServerTerminal.swift`)**
  - Listens for client connections on port `8080`.
  - Echoes back any message received.
  - Graceful shutdown with the `'q'` command (no need to close the terminal).
  
- **TCP Client (`TCPClientTerminal.swift`)**
  - Connects to the TCP server on `localhost:8080`.
  - Allows users to send messages via terminal input.
  - Displays the response from the server in real time.

---

## 🚀 Setup & Usage

### **1️⃣ Run the TCP Server**
1. Open a terminal and navigate to the project folder.
2. Run the server with:
   ```sh
   swift TCPServerTerminal.swift
   ```
3. You should see:
   ```
   ✅ Server started on port 8080
   🛑 Type 'q' and press Enter to stop the server:
   ```

### **2️⃣ Run the TCP Client**
1. Open a second terminal and navigate to the project folder.
2. Start the client with:
   ```sh
   swift TCPClientTerminal.swift
   ```
3. If successful, you'll see:
   ```
   ✅ Connected to the server
   ✉️ Type message: 
   ```
4. Type any message and press **Enter**. It will be sent to the server.

---

## 🛑 Stopping the Server
To **stop the server**, simply type:
```sh
q
```
and press **Enter**. The server will shut down cleanly without closing the terminal.

---

## 🛠️ Troubleshooting

### **❌ Client Fails to Connect**
1. Ensure the **server is running first** before starting the client.
2. Try changing `"127.0.0.1"` to `"localhost"` in `TCPClientTerminal.swift`.
3. Check if another process is using **port 8080**:
   ```sh
   lsof -i :8080
   ```
   If a process is using the port, kill it:
   ```sh
   kill -9 <PID>
   ```
   Then restart the server.

### **🌐 Running Over a Network**
If running the **server and client on different machines**:
- Find the **server's local IP** using:
  ```sh
  ifconfig | grep "inet "
  ```
- In `TCPClientTerminal.swift`, replace `"127.0.0.1"` with the **server's IP**.

---

## 📄 License
This project is open-source and free to use. Modify it as needed!

---

## 🤝 Contributing
Feel free to submit issues or PRs to improve the project! 🚀
