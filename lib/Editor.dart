class EditorMode {
  final int _mode;
  static final COMMAND = const EditorMode(0);
  static final INPUT = const EditorMode(1);
  const EditorMode(int this._mode);
}

class Editor {
  EditorMode _currentMode;
  String _prompt;
  StringBuffer buff;
  User usr;
  
  Editor(this.usr) {
    _currentMode = EditorMode.COMMAND;
    usr.updateHandler(_handleInput);
    buff = new StringBuffer();
  }
  
  void start() {    
    displayPrompt();
  }
  
  void _handleInput() {
    String input = usr.readLine();
    
    if(_currentMode == EditorMode.COMMAND) {
      String cmd;
      String arg;
      int indx = input.indexOf(' ');
      if(indx == -1) {
        cmd = input;
      } else {
        cmd = input.substring(0, indx);
        arg = input.substring(indx);
      }
      switch(cmd) {
      case 'h':
        _printHelp(arg);
        break;
      case 'q':
        _quitEdit();
        break;
      }
    }
  }
  
  void displayPrompt() {
    switch(_currentMode) {
    case EditorMode.COMMAND:
      usr.write(': ');
      break;
    case EditorMode.INPUT:
      usr.write('~ ');
      break;
    }
  }
  
  void _printHelp(String arg) {
    if(arg == null || arg.isEmpty()) {
      // TODO: Write full help information.
      String helpInfo = '''Editor Help:
Editor has two modes. Input and Command mode.
While in input mode your prompt will be '~'. In this mode anything you write
will be added to the buffer a line at a time.
To exit input mode enter '.' on a line by itself (no spaces).
In command mode you may enter various commands to edit, modify and save the 
buffer. They are listed below:
h <cmd>     Display this help. Optionally add <cmd> for more help about that
            command.
i           Insert a line at the current position. Will put you into Input mode.
q           Quit
p <range>   Display the currently line, or optionally the line(s) found in the
            range specified.''';
      usr.writeLine('\n$helpInfo');
      displayPrompt();
    }
  }
  
  void _quitEdit() {
    usr.doneEdit(buff.toString());
  }
}
