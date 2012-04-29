#library('dartmud:connection');

#import('dart:io');

/**
 * Connection class is a wrapper around the client socket connection
 * this wrapper provides some convenience functions and automatically.
 * Connection is part of the base server and not dependant on the
 * mudlib itself.
 */

class Connection {
  Socket _sock;
  StringInputStream _strInput;
  
  /**
   * Constructs a new Connection initialized with a base socket.
   * (Created by on a new connection to ServerSocket.
   * Creates an internal StringInputStream from the received socket
   * and assigns a default onError handler for the socket.
   */
  Connection(this._sock) {
    _strInput = new StringInputStream(_sock.inputStream);
    
    _sock.onError = (Exception e) { 
      print("An error has occurred with Connection#$_sock:");
      print(e);
      _sock.close();
    };
  }
  
  /**
   * Reassigns the onLine function for Socket to [func].
   * Used when we need to modify default command processing behaviour,
   * such as when using internal line editor.
   */
  set onLine(Function func) => _strInput.onLine = func;
  
  /** Write [str] to remote client. Useful for prompting user. */
  int write(String str) {
    List<int> strCodes = str.charCodes();
    _sock.writeList(strCodes, 0, strCodes.length);
  }
  
  /** Write [str] to remote client. Terminates with a newline character */
  int writeLine(String str) => write("$str\n");
  
  /** Returns input line from remote client */
  String readLine() => _strInput.readLine().trim();
  
  /** Notifies and closes remote client's connection */
  void close() {
    writeLine('Goodbye!');
    _sock.close();
  }
}