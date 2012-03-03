class Command {
  static CommandManager cmdDaemon;
  Function onCall;
  String name;
  String _helpInfo;
  
  Command(String this.name, String this._helpInfo, Function this.onCall);
  
  void _runCmd(var conn, String args) => onCall(conn, args);
  
  String get help() => _helpInfo;
}

class CommandManager {
  Map<String, Command> _commands;
  static Mudlib mudlib;
  
  Command operator [](String cmd) => _commands[cmd];
  
  CommandManager() {
    print("..Initializing Command Daemon");
    _commands = new Map<String, Command>();
    Command.cmdDaemon = this;
    _populateCommands();
    Mudlib.cmdDaemon = this;
  }
  
  List<String> get commands() => _commands.getKeys();
  
  void add(Command cmdObj) {
    String cmd = cmdObj.name;
    if(_commands.containsKey(cmd)) {
      throw "Unable to add a duplicate command '$cmd'";
    }
    _commands[cmd] = cmdObj;
  }
  
  void _populateCommands() {
    // Exit Command
    add(new Command('exit',
      '''${Colors.LT_GREEN('Usage: exit')}
Logs you off and disconnects you from the MUD.''',
      (var usr, var args) {
      Room usrRoom = usr.currentRoom;
      usrRoom.removeObject(usr);
      List<User> rmUsers = usrRoom.getUsers();
      for(User tmp in rmUsers) {
        tmp.display('${usr.name} fades from existance.');
      }
      CommandManager.mudlib.disconnect(usr);
      })
    );
    
    // Shutdown command
    add(new Command('shutdown',
      '''${Colors.LT_GREEN('Usage: shutdown')}
Notify and disconnect all users. Halt the MUD server.''',
      (var usr, var args) {
      CommandManager.mudlib.shutdown();
      })
    );
    
    // Broadcast command
    add(new Command('broadcast',
      '''${Colors.LT_GREEN('Usage: broadcast')} <text>
Send a broadcast notification to all users currently logged on.''',
      (var usr, var args) {
      for(User tmp in User.mudlib.users) {
        String who;
        if(tmp === usr) {
          who = 'You broadcast:';
        } else {
          who = 'Broadcast (${usr.name}):';
        }
        tmp.display('${Colors.LT_RED(who)} $args');
      }
      })
    );
    
    // Help command
    // TODO: Add more to this to get help on specific commands.
    add(new Command('help',
      '''${Colors.LT_GREEN('Usage: help')} [<command>]
Without any arguments, help displays a list of available commands.
With optional ${Colors.LT_WHITE('<command>')}, diplay the help information for the specified command.''',
      (User usr, String args) {
      if(args == null || args.isEmpty()) {
        List<String> commands = Command.cmdDaemon.commands;
        commands.sort((String a, String b) => a.compareTo(b));
        StringBuffer buff = new StringBuffer();
        buff.add("${Colors.LT_GREEN('Available commands:')}\n");
        for(String cmd in commands) {
          buff.add('${Colors.LT_WHITE(cmd)}\n');
        }
        buff.add('\nUse help <command> to get more information on a command.');
        usr.display(buff.toString());
      } else {
        Command helpOn = Command.cmdDaemon[args];
        if(helpOn != null) {
          usr.display(helpOn.help);
        } else {
          usr.display("I don't know anything about '$args'.");
        }
      }
      })
    );
    
    add(new Command('look',
      '''${Colors.LT_GREEN('Usage: look')} [at <object>]
Without any arguments, look will show you the current location you are standing
in.
You can also choose to look ${Colors.LT_WHITE('at <object>')}, to get more 
details about the item. The object or item must be in your possession or in the
same location as you.''',
      (User usr, String args) {
      if(args == null || args.isEmpty()) {
        StringBuffer buff = new StringBuffer(usr.currentRoom.description);
        var items = usr.currentRoom.inventory;
        if(items.length - 1 > 0) {
          buff.add("\nYou see here: ");
          for(int i = 0; i < items.length; i++) {
            if(items[i] === usr) continue;
            buff.add('${items[i].short}');
            if(i < items.length - 1) {
              if(!(i == items.length - 2 && usr === items[i + 1])) buff.add(', ');
            }
          }
        }
        usr.display(buff.toString());
      }
      })
    );
    
    add(new Command('home',
      '''${Colors.LT_GREEN('Usage: home')}
Teleports the admin to thier home room.''',
      (User usr, String args) {
      if(!Mudlib.roomDaemon.moveUser(usr, '${usr.name}Home')) {
        usr.display('Unable to move home. An error occured');
        var localUsers = usr.currentRoom.getUsers();
        for(var tmp in localUsers) {
          if(usr === tmp) continue;
          tmp.display('${usr.name} twitches');
        }
      }
    })
    );
    
    add(new Command('who',
      '''${Colors.LT_GREEN('Usage: who')}
Displays a list of users who are currently online.''',
      (User usr, String args) {
      List<User> users = CommandManager.mudlib.users;
      StringBuffer buff = new StringBuffer('${Colors.LT_RED('Currently logged in users:')}\n');
      for(int i = 0; i < users.length; i++) {
        buff.add(users[i].name);
        if(i < users.length - 1) buff.add('\n');
      }
      usr.display(buff.toString());
    })
    );
    
    add(new Command('say', 
      '''${Colors.LT_GREEN('Usage: say')} <text>
Speak to the others in the current room.''',
      (User usr, String args) {
      List users = usr.currentRoom.getOtherUsers(usr);
      usr.display('You say: $args');
      for(User tmp in users) {
        tmp.display('${usr.name} says: $args');
      }
    })
    );
    
    add(new Command('emote', 
      '''${Colors.LT_GREEN('Usage: emote')} <actions>
Displays to others in the room that you perform the ${Colors.LT_WHITE('actions')}.
Eg: emote jumps up and down.
Will display to others in the room: <yourname> jumps up and down.''',
      (User usr, String args) {
      if(args == null || args.isEmpty()) {
        usr.display('emote what?');
      } else {
        List users = usr.currentRoom.getOtherUsers(usr);
        String action = '${usr.name} $args';
        usr.display('You emote: $action');
        for(User tmp in users) {
          tmp.display(action);
        }
      }
      })
    );
  
  
  } // End of _populateCommands
} // End of CommandManager class
  
