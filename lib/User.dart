class User extends ContainerImpl {
  static Mudlib mudlib;
  Connection _conn;
  StringInputStream _strInput;
  int loggedIn;
  String _prompt;
  Room currentRoom;
  Map _userData;
  String _bufferData;
  Function _editCallback;
  
  User(this._conn) {
    // Initialize connection stuff
    loggedIn = 0;
    
    // Initialize User specific stuff
    _userData = new Map();
    _prompt = '> ';
  }
  
  User.FromMap(this._conn, this._userData) : super('temp')  {
    _shortDescription = _userData['username'];
    _longDescription = _userData['longDesc'];
    _prompt = _userData['prompt'];
    
    _conn.onLine = _handleInput;
  }
  
  void display(String str) {
    _conn.writeLine('\n$str');
    prompt();
  }
  
  void writeLine(String str) { _conn.writeLine(str);  }
  
  void write(String str) { _conn.write(str); }
  
  void updateHandler(Function handler) {
    _conn.onLine = handler;
  }
  
  void startEdit(Function callback) {
    _editCallback = callback;
    _bufferData = null;
    Editor edit = new Editor(this);
    edit.start();
  }
  
  void doneEdit(String info) {
    _bufferData = info;
    _conn.onLine = _handleInput;
    _editCallback(info);
  }
  
  String readLine() => _conn.readLine();
  
  void _handleInput() {
    String line = _conn.readLine();
    
    User.mudlib.processCmd(this, line);
  }
  
  void prompt() { _conn.write(_prompt); }
  
  void close() {
    _userData['longDesc'] = _longDescription;
    _userData['prompt'] = _prompt;
    // TODO: Make sure to populate user info such as experience, health, etc
    
    Mudlib.saveUser(_userData);
    _conn.close();
  }
  
  void set promptStr(String prmpt) {
    if(prmpt != null || !prmpt.isEmpty()) _prompt = prmpt;
  }
}
