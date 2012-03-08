#library("dartmud:server");

#import("dart:builtin"); // Temp fix for this Editor version
#import("dart:io");
#import('Connection.dart');
#import("lib/Mudlib.dart");

class ServerManager {
  ServerSocket _listenSocket;
  Mudlib _mudlib;
  
  // Create a socket to listen on
  ServerManager() {
    _mudlib = new Mudlib(this);
    _listenSocket = new ServerSocket("127.0.0.1", 5700, 0);
    print("DartMud server now running on 127.0.0.1 port 5700");
    
    if(_listenSocket == null) {
      throw "Error: Unable to open Server Socket";
    }
    
    _listenSocket.onConnection = this._handleConn;
    _listenSocket.onError = () {
      print("Error occured with ServerSocket!");
    };
  }
  
  void _handleConn(Socket sock) {
    Connection conn = new Connection(sock);
    _mudlib.login(conn);
    print("Connection from: $sock");

  }
    
  // Shutdown the server.
  // Call each Connection, send notice and close their connection.
  void shutdown() {
    print("Stopping server!");
    _listenSocket.close();
  }
  
}

void main() {
  ServerManager server = new ServerManager();
  
}
