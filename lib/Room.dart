class RoomManager implements Manager {
  static Mudlib mudlib;
  Map<String, Room> _rooms;
  Map<String, Function> _roomFuncs;
  
  RoomManager() {
    print("..Initializing Room Daemon");
    _rooms = new Map<String, Room>();
    _roomFuncs = new Map<String, Function>();
    add(() {
      return new Room('void', 'The Void',
      '''You are standing in the mists of the void. This is the place of
nothingness. The most minimal of rooms to prevent any errors from occuring.''');
    });
    Mudlib.roomDaemon = this;
  }
  
  void add(Function roomFunc) {
    Room room = roomFunc();
    if(room != null) {
      String roomId = room._id;
      if(_roomFuncs.containsKey(roomId)) {
        throw "Unable to add room ${room.name}. Conflicting ID: ${room._id}";
      }
      _roomFuncs[roomId] = roomFunc;
    }
  }
  
  Room operator [](String roomId) => (_roomFuncs.containsKey(roomId) ? 
      _rooms.putIfAbsent(roomId, _roomFuncs[roomId]) : null );
  
  void remove(String roomId) {
    _rooms.remove(roomId);
  }
  
  void removeRoom(Room room) {
    remove(room._id);
  }
  
  bool moveUser(User usr, String roomId) {
    Room curRoom = usr.currentRoom;
    Room newRoom = this[roomId];
    
    if(newRoom != null) {
      if(curRoom != null) curRoom.removeObject(usr);
      if(!newRoom.addObject(usr)) {
        Mudlib.roomDaemon['void'].addObject(usr);
      }
      Mudlib.cmdDaemon['look'].onCall(usr, null);
      return true;
    } else {
      return false;
    }
  }
  
}

class Room extends ContainerImpl {
  Map<String, String> _exits;
  String _id;

  Room(String this._id, String name, [String description = "You are standing in the midst of the void"]) : super(name, description) {
    _exits = new Map<String, String>();
  }
  
  bool addExit(String dir, String id) {
    bool res;
    if(_exits.containsKey(dir)) {
      res = false;
      throw "The room already has an exit to the $dir";
    } else {
      _exits[dir] = id;
      res = true;
    }
    
    return res;
  }
  
  bool addObject(var obj) {
    if(hasObject(obj)) return false;
    _inventory.add(obj);
    if(obj is User) obj.currentRoom = this;
    return true;
  }
  
  List getUsers() => _inventory.filter((var obj) => obj is User);
  
  List getOtherUsers(User curUser) => getUsers().filter((User usr) => usr != curUser);
  
  bool hasExit(String exit) => _exits.containsKey(exit);
  
  String getExit(String direction) => _exits[direction];
  
  String get description() {
    StringBuffer buff = new StringBuffer(_shortDescription);
    buff.add('\n');
    buff.add(_longDescription);
    buff.add('\n');
    if(!this._exits.isEmpty()) {
      buff.add('Exits: ');
      List<String> exitDirs = _exits.getKeys();
      for(int i = 0; i < exitDirs.length; i++) {
        buff.add(exitDirs[i]);
        if(i < exitDirs.length - 1) buff.add(', ');
      }
    } else {
      buff.add('You see no exits.');
    }
    return buff.toString();
  }
}
