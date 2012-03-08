class Login {
  static Mudlib mudlib;
  
  static final int LOGIN = 0;
  static final int EXISTING_USER = 1;
  static final int EXISTING_PASS = 2;
  static final int NEW_USER = 3;
  static final int NEW_PASS = 4;
  static final int NEW_PASS2 = 5;
  static final int USR_MIN_LENGTH = 4;
  static final int MAX_TRIES = 3;
  
  Connection _connect;
  int _loggedIn;
  int _usernameTries;
  int _passwordTries;
  String username;
  String password;
  String _userData;
  Map<String, String> _mapData;
  
  Login(this._connect) {
    _connect.onLine = _handleInput;
    _loggedIn = 0;
    _usernameTries = 0;
    _passwordTries = 0;
    _mapData = new Map<String, String>();
    _mapData['prompt'] = '> ';
  }
  
  void promptLogin() {
    StringBuffer buff = new StringBuffer();
    buff.add('\n');
    buff.add('Welcome to DartMud!\n\n');
    buff.add('Do you wish to [C]reate an account or [L]ogin?: ');
    _connect.write(buff.toString());
  }
  
  void _handleInput() {
    String line = _connect.readLine();
    
    switch(_loggedIn) {
    case Login.LOGIN:
      _receivedCreateOrLogin(line);
      break;
    case Login.EXISTING_USER:
      _receivedExistingUsername(line);
      break;
    case Login.EXISTING_PASS:
      _receivedExistingPassword(line);
      break;
    case Login.NEW_USER:
      _receivedNewUsername(line);
      break;
    case Login.NEW_PASS:
      _receivedNewPassword(line);
      break;
    case Login.NEW_PASS2:
      _receivedNewPasswordConfirmation(line);
      break;
    }
    
  }
  
  void _receivedCreateOrLogin(String line) {
    if(line != null && !line.isEmpty()) {
      String char = line[0].toLowerCase();
      if(char == 'l') {
        _loggedIn = Login.EXISTING_USER;
        _connect.write('Please enter your username: ');
      } else if(char == 'c') {
        _loggedIn = Login.NEW_USER;
        _connect.write('\n\nPlease choose a username for your new character: ');
      } else {    
        _connect.write('Please choose C or L to create or login: ');
      }
    } else {
      _connect.write('Please choose C or L to create or login: ');
    }
  }
  
  void _receivedExistingUsername(line) {
    Map userData = Mudlib.loadUser(line);
    if(userData != null) {
      _mapData = userData;
      _loggedIn = Login.EXISTING_PASS;
      _connect.write('Please enter your password: ');
    } else if(line.toLowerCase() == 'create') {
      _loggedIn = Login.NEW_USER;
      _connect.writeLine('You have choosen to create a new user.');
      _connect.write('\n\nPlease choose a new username: ');
    } else {
      if(++_usernameTries == Login.MAX_TRIES) {
        _connect.writeLine('\nToo many failed attempts. Now disconnecting!');
        _connect.close();
      } else {
        _connect.writeLine('\n$line is not a valid username.');
        _connect.write('Please enter your username or choose \'create\': ');
      }
    }
    
  }
  
  void _receivedExistingPassword(line) {
    // TODO: Verify password matches that on file for a user
    if(line == _mapData['password']) {
      Login.mudlib.addUser(new User.FromMap(_connect, _mapData));
    } else {
      if(++_passwordTries >= Login.MAX_TRIES) {
        _connect.writeLine('\nToo many failed attempts. Now disconnecting!');
        _connect.close();
      } else {
        _connect.write('\nInvalid password. Try again: ');
      }
    }
    
  }
  
  void _receivedNewUsername(String line) {
    //TODO: Write better validation stuff for username
    String message;
    if(line.length < Login.USR_MIN_LENGTH) {
      message =
'''That username is too short.
Please choose a username at least ${Login.USR_MIN_LENGTH} characters long: ''';
    } else if(line.contains(' ')) {
      message = '''Username may not contain spaces.
Please use a username which only contains letters: ''';
    } else {
      _mapData['username'] = line;
      _loggedIn = Login.NEW_PASS;
      message = 'Please choose a password of at least ${Login.USR_MIN_LENGTH} characters: ';
    }
    _connect.write(message);
    
  }
  
  void _receivedNewPassword(line) {
    String message;
    if(line.length < Login.USR_MIN_LENGTH) {
      message = 
'''Your password must be at least ${Login.USR_MIN_LENGTH} characters long.
Please choose a password: ''';
    } else {
      _loggedIn = Login.NEW_PASS2;
      message = 'Please confirm your password: ';
      _mapData['password'] = line;
    }
    _connect.write(message);
  }
  
  void _receivedNewPasswordConfirmation(line) {
    String message;
    if(line != _mapData['password']) {
      if(++_passwordTries >= Login.MAX_TRIES) {
        _connect.writeLine('\nToo many failed attempts. Now disconnecting!');
        _connect.close();
      } else {
        _loggedIn = Login.NEW_PASS;
        _connect.write('Your passwords do not match. Please choose a password: ');
      }
    } else {
      Mudlib.saveUser(_mapData);
      Login.mudlib.addUser(new User.FromMap(_connect, _mapData));
    }
  }
}
