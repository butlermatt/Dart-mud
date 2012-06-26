class EditorMode {
  static final int COMMAND = 0;
  static final int INPUT  = 1;
}

class Range {
  int _lower;
  int _upper;
  int _length;
  
  Range(String rng) {
    List rangeArgs = rng.split(',');
    if(rangeArgs.length == 1) {
      int value = Math.parseInt(rangeArgs[0]);
      _lower = value;
      _upper = value;
      _length = 1;
    } else {
      int value1 = Math.parseInt(rangeArgs[0]);
      int value2;
      
      if(rangeArgs[1].trim() == '\$') {
        // Temporary 'upper limit' value. Unlikely someone will write a buffer
        // With that many lines.
        value2 = 9999; 
        
      } else {
        value2 = Math.parseInt(rangeArgs[1]);
      }
      
      if(value1 >  value2) {
        throw const BadNumberFormatException('Range should be in the format of <lowerValue>,<upperValue>');
      }
      
      _lower = value1;
      _upper = value2;
      _length = value2 - value1 + 1; // Ranges are inclusive so add an extra value;
    }
  }
  
  bool contains(int value) => (value >= _lower) && (value <= _upper);
  
  int get length() => _length;
  
  int get first() => _lower;
  int get last() => _upper;
}

class Editor {
  var _currentMode;
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
      case 'c':
        _changeLines(arg);
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
    if(arg == null || arg.isEmpty()) {
      usr.write("${Colors.LT_WHITE('$_curLine :')} ${_fullBuff[_curLine - 1]}");
    } else {
      Range range;
      try {
        range = new Range(arg);
      } catch(BadNumberFormatException e) {
        String error = 'Error: Please use the range in the format of <lowerValue>,<upperValue>';
        usr.writeLine(Colors.LT_RED(error));
      }
      if(range != null && range.first > _fullBuff.length) {
        String error = 'Error: Please use the range in the format of <lowerValue>,<upperValue>';
        usr.writeLine(Colors.LT_RED(error));
      } else if(range != null) {
        int i = (range.first - 1);
        int end = (range.last <= _fullBuff.length ? range.last : _fullBuff.length);
        for(i; i < end; i++) {
          usr.write('${Colors.LT_WHITE('${i + 1} :')} ${_fullBuff[i]}');
          // Don't need extra line return because each sentence has one already.
        }
        _curLine = end;
      }
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
c <range>   Change the current line, or optionally, the line(s) found in the
            range specified. This will delete the line(s) and insert any new
            text into that range.
p <range>   Display the currently line, or optionally the line(s) found in the
            range specified.
d <range>   Deletes the current line, or optionally, the line(s) found in the
            range specified.
q           Quit editor, returning anything currently in the buffer.''';
      usr.writeLine('\n$helpInfo');
      displayPrompt();
    }
  }
  
  void _deleteLines(String args) {
    if(args == null || args.isEmpty()) {
      _fullBuff.removeRange((_curLine - 1), 1);
      if(_curLine > _fullBuff.length) _curLine -= 1;
    } else {
      Range range;
      try {
        range = new Range(args);
      } catch(BadNumberFormatException e) {
        String error = 'Error: Please use the range in the format of <lowerValue>,<upperValue>';
        usr.writeLine(Colors.LT_RED(error));
      }
      if(range != null && range.first > _fullBuff.length) {
        String error = 'Error: Please use the range in the format of <lowerValue>,<upperValue>';
        usr.writeLine(Colors.LT_RED(error));
      } else if(range != null) {
        int strt = (range.first - 1);
        int end = (range.last <= _fullBuff.length ? range.last : _fullBuff.length);
        int length = end - strt;
        _fullBuff.removeRange(strt, length);
        _curLine = (range.first <= _fullBuff.length ? range.first : _fullBuff.length);
      }
    }
    displayPrompt();
  }
  
  void _changeLines(String args) {
    if(_fullBuff.isEmpty()) {
      _curLine = 0;
      _currentMode = EditorMode.INPUT;
    } else if(args == null || args.isEmpty()) {
      _currentMode = EditorMode.INPUT;
      _curLine -= 1; 
      _fullBuff.removeRange(_curLine, 1);
    } else {
      Range range;
      
      try {
        range = new Range(args);
      } catch(BadNumberFormatException e) {
        String error = 'Error: Please use the range in the format of <lowerValue>,<upperValue>';
        usr.writeLine(Colors.LT_RED(error));
      }
      
      if(range != null && range.first > _fullBuff.length) {
        String error = 'Error: Please use the range in the format of <lowerValue>,<upperValue>';
        usr.writeLine(Colors.LT_RED(error));
      } else if(range != null) {
        _currentMode = EditorMode.INPUT;
        int strt = (range.first - 1);
        int end = (range.last <= _fullBuff.length ? range.last : _fullBuff.length);
        int length = end - strt;
        _fullBuff.removeRange(strt, length);
        _curLine = (range.first <= _fullBuff.length ? range.first : _fullBuff.length);
        _curLine -= 1;
      }
    }
    
    displayPrompt();
  }
  
  void _quitEdit() {
    String res;
    if(_fullBuff.length === 0 || _fullBuff.isEmpty()) {
      res = '';
    } else {
      res = Strings.concatAll(_fullBuff);
    }
    usr.doneEdit(res);
  }
}
