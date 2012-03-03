class Colors {
  static final int RESET = 0;
  static final int BOLD = 1;
  
  static final int FG_BLACK = 30;
  static final int FG_RED = 31;
  static final int FG_GREEN = 32;
  static final int FG_YELLOW = 33;
  static final int FG_BLUE = 34;
  static final int FG_MAGENTA = 35;
  static final int FG_CYAN = 36;
  static final int FG_WHITE = 37;
  
  static final int BG_BLACK = 40;
  static final int BG_RED = 41;
  static final int BG_GREEN = 42;
  static final int BG_YELLOW = 43;
  static final int BG_BLUE = 44;
  static final int BG_MAGENTA = 45;
  static final int BG_CYAN = 46;
  static final int BG_WHITE = 47;
  
  static String _formatString(String str, int color, bool bold) {
    String stCd = new String.fromCharCodes([27, 91]);
    return '${stCd}${bold ? '01' : ''};${color}m$str${stCd}${Colors.RESET}m';
  }
  
  static String LT_RED(String arg) => _formatString(arg, Colors.FG_RED, true);
  static String DK_RED(String arg) => _formatString(arg, Colors.FG_RED, false);
  
  static String LT_GREEN(String arg) => _formatString(arg, Colors.FG_GREEN, true);
  static String DK_GREEN(String arg) => _formatString(arg, Colors.FG_GREEN, false);
  
  static String LT_YELLOW(String arg) => _formatString(arg, Colors.FG_YELLOW, true);
  static String DK_YELLOW(String arg) => _formatString(arg, Colors.FG_YELLOW, false);
  
  static String LT_BLUE(String arg) => _formatString(arg, Colors.FG_BLUE, true);
  static String DK_BLUE(String arg) => _formatString(arg, Colors.FG_BLUE, false);
  
  static String LT_MAGENTA(String arg) => _formatString(arg, Colors.FG_MAGENTA, true);
  static String DK_MAGENTA(String arg) => _formatString(arg, Colors.FG_MAGENTA, false);
  
  static String LT_CYAN(String arg) => _formatString(arg, Colors.FG_CYAN, true);
  static String DK_CYAN(String arg) => _formatString(arg, Colors.FG_CYAN, false);
  
  static String LT_WHITE(String arg) => _formatString(arg, Colors.FG_WHITE, true);
  static String DK_WHITE(String arg) => _formatString(arg, Colors.FG_WHITE, false);
  
  static String LT_BLACK(String arg) => _formatString(arg, Colors.FG_BLACK, true);
  static String DK_BLACK(String arg) => _formatString(arg, Colors.FG_BLACK, false);
  
}
