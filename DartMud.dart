#library("dartmud:server");

#import("dart:io");
#import('Connection.dart');
#import("lib/Mudlib.dart");

/**
 * ServerManager class opens server connection, creates a Connection
 * and hands it off to the mudlib.
 */
class ServerManager {
  ServerSocket _listenSocket;
  Mudlib _mudlib;
  
  /** Create a new ServerSocket to listen on. Throws error if fails */
  ServerManager() {
    _mudlib = new Mudlib(this);
    _listenSocket = new ServerSocket("127.0.0.1", 5700, 0);
    print("DartMud server now running on 127.0.0.1 port 5700");
    
    if(_listenSocket == null) {
      throw "Error: Unable to open Server Socket";
    }
    
    _listenSocket.onConnection = this._handleConn;
    _listenSocket.onError = (Exception e) {
      print("Error occured with ServerSocket!:");
      print(e);
    };
  }
  
  /**
   * On connection to ServerSocket, creates a new Connection object
   * and hands it off to the mudlib. Prints connection log to console.
   */
  void _handleConn(Socket sock) {
    Connection conn = new Connection(sock);
    _mudlib.login(conn);
    print("Connection from: ${sock.remoteHost}:${sock.remotePort}");

  }
    
  /** Shutdown the server. */
  void shutdown() {
    print("Stopping server!");
    _listenSocket.close();
  }
  
}

void main() {
  ServerManager server = new ServerManager();
  
}
