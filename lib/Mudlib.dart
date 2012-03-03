#library("dartmud:mudlib");

#import("dart:io");
#import("dart:json");
#import('../Connection.dart');

#source("Commands.dart");
#source('Login.dart');
#source('User.dart');
#source('GameObject.dart');
#source('Room.dart');
#source('Container.dart');
#source('Manager.dart');
#source('./rooms/Matt.dart');
#source('Colors.dart');


class Mudlib {
  static CommandManager cmdDaemon;
  static RoomManager roomDaemon;
  var _server;
  List<User> users;
  
  Mudlib(var server) {
    print("Initializing Mudlib");
    _server = server;
    
    CommandManager.mudlib = this;
    cmdDaemon = new CommandManager();
        
    RoomManager.mudlib = this;
    roomDaemon = new RoomManager();
    
    User.mudlib = this;
    Login.mudlib = this;
    
    users = new List<User>();
    Matt.Initialize();
  }
  
  void login(Connection sock) {
    Login usr = new Login(sock);

    usr.promptLogin();
  }
  
  static void saveUser(Map usrData) {
    String data = JSON.stringify(usrData);
    
    File usrFile = new File('users/${usrData['username']}.usr');
    RandomAccessFile file = usrFile.openSync(FileMode.WRITE);
    file.writeStringSync(data);
    file.closeSync();
  }
  
  static Map loadUser(String user) {
    String usrDataStr;
    File usrFile = new File('users/$user.usr');
    if(usrFile.existsSync()) {
      usrDataStr = usrFile.readAsTextSync();
      return JSON.parse(usrDataStr);
    } else {
      return null;
    }
  }
  
  // Remove a user from the list
  // then disconnect their session.
  void disconnect(User usr) {
    _removeUser(usr);
    usr.close();
  }
  
  // Disconnect all users
  void disconnectAll() {
    while(!users.isEmpty()) {
      User usr = users[0];
      usr.writeLine(Colors.LT_RED('The server is shutting down. Now disconnecting you.'));
      disconnect(usr);
    }
  }
  
  // Disconnect all sessions then call server shutdown
  void shutdown() {
    disconnectAll();
    _server.shutdown();
  }
  
  // Remove a session from list of current users.
  void _removeUser(User conn) {
    int connIndx = users.indexOf(conn);
    users.removeRange(connIndx, 1);
  }
  
  void addUser(User conn) {
    users.add(conn);
    Mudlib.roomDaemon.moveUser(conn, 'void');
  }
  
  void processCmd(User conn, String cmd) {
    if(cmd.isEmpty() || cmd == null) {
      conn.display('Huh?');
      return;
    }
    // Find, and extract any arguments to command.    
    int spaceInd = cmd.indexOf(' ');
    String args;
    if(spaceInd != -1) {
      args = cmd.substring(spaceInd + 1).trim();
      cmd = cmd.substring(0, spaceInd);
    }
    
    // Make sure we interpret the command itself as all lowercase.
    cmd = cmd.toLowerCase();
    
    // Find the function for command.
    Command cmdObj = cmdDaemon[cmd];
    
    if(cmdObj != null) {
      cmdObj._runCmd(conn, args);

    // The cmd given isn't a system command. check room exits.
    } else if(conn.currentRoom.hasExit(cmd)) {
      if(!roomDaemon.moveUser(conn, conn.currentRoom.getExit(cmd))) {
        roomDaemon.moveUser(conn, 'void');
        conn.display('An error occurred. Transporting you to the void instead.');
      }
    } else {
      conn.writeLine("I don't know how to '$cmd' yet");
      conn.prompt();      
    }
  } 

}