#library('dartmud:connection');

#import('dart:io');

class Connection {
  Socket _sock;
  StringInputStream _strInput;
  
  Connection(this._sock) {
    _strInput = new StringInputStream(_sock.inputStream);
    
    _sock.errorHandler = () { 
      print("An error has occurred with Connection#$_sock");
      _sock.close();
    };
  }
  
  set lineHandler(Function func) => _strInput.lineHandler = func;
  
  int write(String str) {
    List<int> strCodes = str.charCodes();
    _sock.writeList(strCodes, 0, strCodes.length);
  }
  
  int writeLine(String str) => write("$str\n");
  
  String readLine() => _strInput.readLine().trim();
  
  void close() {
    writeLine('Goodbye!');
    _sock.close();
  }
}