interface Container default ContainerImpl {
  /**
   * Returns [GameObject] with the name [name]
   * Does not remove from [Container] 
   */
  GameObject getObject(String name);
  
  /**
   * Returns true if this [Container] contains a [GameObject] with the name [name]
   */
  bool hasObjectByName(String name);
  
  /**
   * Returns true if this [Container] contains [GameObject]
   */
  bool hasObject(GameObject obj);
  
  /**
   * Tries to add [GameObject] to this [Container]
   * Returns true if successful
   * Returns false is [GameObject] already exists in this [Container]
   */
  bool addObject(GameObject obj);
  
  /**
   * Tries to remove [GameObject] obj from [Container]
   * Returns true if successful, false on fail
   */
  bool removeObject(GameObject obj);
  
  /**
   * Tries to remove [GameObject] by [name] from [Container]
   * Returns [GameObject] if successful. Returns [:null:] on failure.
   */
  GameObject removeByName(String name);
}

class ContainerImpl extends GameObject implements Container {
  List<GameObject> _inventory;
  
  ContainerImpl(String name, [String description]) : super(name, description) {
    _inventory = new List<GameObject>();
  }
  
  GameObject getObject(String name) {
    GameObject res = null;
    for(var x in _inventory) {
      if(x.name == name) res = x;
    }
    
    return res;
  }
  
  bool hasObjectByName(String name) => (getObject(name) != null);
  
  bool hasObject(GameObject obj) => (_inventory.indexOf(obj) != -1);
  
  bool addObject(GameObject obj) {
    if(hasObject(obj)) return false;
    _inventory.add(obj);
    return true;
  }
  
  bool removeObject(GameObject obj) {
    int indx = _inventory.indexOf(obj);
    bool res;
    if(indx == -1) {
      res = false;
    } else {
      _inventory.removeRange(indx, 1);
      res = true;
    }
    
    return res;
  }
  
  GameObject removeByName(String name) {
    GameObject obj = getObject(name);
    if(obj != null) removeObject(obj);
    return obj;
  }
  
  List get inventory() => _inventory;
}