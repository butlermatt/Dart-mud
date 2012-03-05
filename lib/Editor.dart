class EditorMode {
  final int _mode;
  static final COMMAND = const EditorMode(0);
  static final INPUT = const EditorMode(1);
  const EditorMode(int this._mode);
}

class Editor {
  EditorMode _currentMode;
  String _prompt;
  List<String> _fullBuff;
  List<String> _tmpBuff;
  int _buffLength;
  int _tmpLength;
  int _curLine;
  User usr;
  
  Editor(this.usr) {
    _currentMode = EditorMode.COMMAND;
    usr.updateHandler(_handleInput);
    _fullBuff = new List<String>();
    _tmpBuff = new List<String>();
    _buffLength = 0;
    _tmpLength = 0;
    _curLine = 1;
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
      case 'i':
        _currentMode = EditorMode.INPUT;
        if(_curLine > 0) _curLine -= 1;
        displayPrompt();
        break;
      case 'a':
        _currentMode = EditorMode.INPUT;
        if(_fullBuff.isEmpty()) _curLine = 0;
        displayPrompt();
        break;
      case 'p':
        _printLines(arg);
        break;
      case 'd':
        _deleteLines(arg);
        break;
      }
    } else if(_currentMode == EditorMode.INPUT) {
      if(input == '.') {
        _currentMode = EditorMode.COMMAND;
        
        _fullBuff.insertRange(_curLine, _tmpBuff.length);
        _fullBuff.setRange(_curLine, _tmpBuff.length, _tmpBuff);
        _curLine += _tmpBuff.length;
        _tmpBuff = new List<String>();
      } else {
        _tmpBuff.add('$input\n');
      }
      displayPrompt();
    }
  } // end Handle Input
  
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
  
  void _printLines(String arg) {
    if(arg === null || arg.isEmpty()) {
      usr.write("${Colors.LT_WHITE('$_curLine :')} ${_fullBuff[_curLine - 1]}");
    }
    displayPrompt();
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
i           Start editing on the line before the current line. Puts you into
            EDIT mode.
a           Start editing on the line after the current line. Puts you into
            EDIT mode.
q           Quit editor, returning anything currently in the buffer.
p <range>   Display the currently line, or optionally the line(s) found in the
            range specified.
d <range>   Deletes the current line, or optionally, the line(s) found in the
            range specified.''';
      usr.writeLine('\n$helpInfo');
      displayPrompt();
    }
  }
  
  void _deleteLines(String args) {
    if(args == null || args.isEmpty()) {
      _fullBuff.removeRange((_curLine - 1), 1);
      if(_curLine > _fullBuff.length) _curLine -= 1;
    }
    displayPrompt();
  }
  
  void _quitEdit() {
    StringBuffer resBuff = new StringBuffer();
    String res;
    if(_fullBuff.length === 0 || _fullBuff.isEmpty()) {
      res = '';
    } else {
      res = resBuff.addAll(_fullBuff).toString().trim();
    }
    usr.doneEdit(res);
  }
}
