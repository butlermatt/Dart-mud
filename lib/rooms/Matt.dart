class Matt {
  static Initialize() {
    print("...Initializing Matt's rooms");
    RoomManager rmMan = Mudlib.roomDaemon;
    rmMan.add(() {
      String description =
'''You find yourself standing in the midst of a simple workshop. Various tools
line the walls to either side. A simple workbench sits off to the side, covered
in a thick layer of sawdust.''';

      Room room = new Room('MattHome', 'Simple Workshop', description);
      room.addExit('north', 'ZoneTest');
      return room;
    });
    
    rmMan.add(() {
      String description =
'''The town square is a rather small area where many in the town congregate
throughout the day. A small fountain, long since dried up, stands in the middle
of the square. Many of the cobble stone bricks have worked loose leaving the
ground rather uneven.''';
      Room room = new Room('ZoneTest', 'Maliche Square', description);
      room.addExit('portal', 'MattHome');
      return room;
    });
  }
}
