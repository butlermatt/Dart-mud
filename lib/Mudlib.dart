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
#source('Editor.dart');

/** 
 * Mudlib handles all game logic. Trying, when possible, to keep it
 * distinct from server logic used to handle the raw connections
 */

class Mudlib {
  /** Reference to CommandManager object */
  static CommandManager cmdDaemon;
  /** Refernece to RoomManager object */
  static RoomManager roomDaemon;
  var _server;
  /** List of logged in users */
  List<User> users;
  
  /**
   * Initializes primary mudlib components including CommandManager,
   * RoomManager, and Areas. */
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
  
  /**
   * Called once an initial Connection has been established.
   * Creates a new Login Object and calls inital login prompt.
   */
  void login(Connection sock) {
    Login usr = new Login(sock);

    usr.promptLogin();
  }
  
  /** 
   * Accepts a mapping of current User data, uses JSON to
   * Stringify data and save it _syncronously_ to a file.
   */
  static void saveUser(Map usrData) {
    String data = '${JSON.stringify(usrData)}\n';
    
    File usrFile = new File('users/${usrData['username']}.usr');
    RandomAccessFile file = usrFile.openSync(FileMode.WRITE);
    file.writeStringSync(data);
    file.closeSync();
  }
  
  /**
   * Accepts [user] name and _syncronously_ checks for previously
   * saved file. If located, _syncronously_ reads file and returns
   * a map of User data
   */
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
  
  /**
   * removes [usr] from the users list then closes their connection.
   */
  void disconnect(User usr) {
    _removeUser(usr);
    usr.close();
  }
  
  /**
   * calls [disconnect] on all users currently logged in.
   */
  void disconnectAll() {
    //TODO: Just realized this may cause an issue if users is only at
    // Login stage of connection. Look into this!!
    while(!users.isEmpty()) {
      User usr = users[0];
      usr.writeLine(Colors.LT_RED('The server is shutting down. Now disconnecting you.'));
      disconnect(usr);
    }
  }
  
  /**
   * Calls [disconnectAll] to remove all active connections safely,
   * then calls server shutdown.
   */
  void shutdown() {
    disconnectAll();
    _server.shutdown();
  }
  
  // Remove a session from list of current users.
  void _removeUser(User conn) {
    int connIndx = users.indexOf(conn);
    users.removeRange(connIndx, 1);
  }
  
  /**
   * This is called after a successful login.
   * Adds user to list of active users, and moves the user to a
   * starting room. In the future this will move user to their last
   * logged in room
   */
  void addUser(User conn) {
    users.add(conn);
    Mudlib.roomDaemon.moveUser(conn, 'void');
    //TODO: Send user to somewhere other than the void by default.
    // Establish a small area and have them default to that start area.
  }
  
  /**
   * called when an input string [cmd] has been received from 
   * user [conn]. Process input to see if it is a valid command
   * or the name of an exit from a room.
   */
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