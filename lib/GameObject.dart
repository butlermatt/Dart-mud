class GameObject {
  String _longDescription;
  String _shortDescription;
  
  GameObject(String this._shortDescription, [String this._longDescription = "The devs were too lazy to provide a description"]);
  
  /**
   * Returns the long description of an Object
   */
  String get long() => _longDescription;
  /** 
   * Sets the long description of an Object
   */
  void set long(String desc) {
    if(desc != null && !desc.isEmpty()) _longDescription = desc;
  }
  
  /**
   * Alias of get [GameObject#name]
   */
  String get short() => name;
  /**
   * Alias of set [GameObject#name]
   */
  void set short(String desc) { name = desc; }
  
  /**
   * Returns the name, or short description, of an Object
   */
  String get name() => _shortDescription;
  /**
   * Sets the name, or short description, of an Object
   */
  void set name(String desc) {
    if(desc != null && !desc.isEmpty()) _shortDescription = desc;
  }
  
  String get description() => '$_shortDescription\n$_longDescription';
}
