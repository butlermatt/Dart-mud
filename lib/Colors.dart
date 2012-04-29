/**
 * Colors class provides simple access methods for providing
 * ansi colors. Note that there is currently no terminal capabilities
 * checking to ensure clients can properly interpret ansi code. But
 * the likelyhood of running into non-ansi capable clients is fairly low.
 */
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
  
  /** Returns string [arg] with light (or bold) red text */
  static String LT_RED(String arg) => _formatString(arg, Colors.FG_RED, true);
  /** Returns string [arg] with dark red text */
  static String DK_RED(String arg) => _formatString(arg, Colors.FG_RED, false);
  
  /** Returns string [arg] with light (or bold) green text */
  static String LT_GREEN(String arg) => _formatString(arg, Colors.FG_GREEN, true);
  /** Returns string [arg] with dark green text */
  static String DK_GREEN(String arg) => _formatString(arg, Colors.FG_GREEN, false);
  
  /** Returns string [arg] with light (or bold) yellow text */
  static String LT_YELLOW(String arg) => _formatString(arg, Colors.FG_YELLOW, true);
  /** Returns string [arg] with dark yellow text */
  static String DK_YELLOW(String arg) => _formatString(arg, Colors.FG_YELLOW, false);
  
  /** Returns string [arg] with light (or bold) blue text */
  static String LT_BLUE(String arg) => _formatString(arg, Colors.FG_BLUE, true);
  /** Returns string [arg] with dark blue text */
  static String DK_BLUE(String arg) => _formatString(arg, Colors.FG_BLUE, false);
  
  /** Returns string [arg] with light (or bold) magenta text */
  static String LT_MAGENTA(String arg) => _formatString(arg, Colors.FG_MAGENTA, true);
  /** Returns string [arg] with dark magenta text */
  static String DK_MAGENTA(String arg) => _formatString(arg, Colors.FG_MAGENTA, false);
  
  /** Returns string [arg] with light (or bold) cyan text */
  static String LT_CYAN(String arg) => _formatString(arg, Colors.FG_CYAN, true);
  /** Returns string [arg] with dark cyan (teal) text */
  static String DK_CYAN(String arg) => _formatString(arg, Colors.FG_CYAN, false);
  
  /** Returns string [arg] with light (or bold) white text */
  static String LT_WHITE(String arg) => _formatString(arg, Colors.FG_WHITE, true);
  /** Returns string [arg] with dark white (light gray) text */
  static String DK_WHITE(String arg) => _formatString(arg, Colors.FG_WHITE, false);
  
  /** Returns string [arg] with light (or bold) black (dark grey) text */
  static String LT_BLACK(String arg) => _formatString(arg, Colors.FG_BLACK, true);
  /** Returns string [arg] with dark black text */
  static String DK_BLACK(String arg) => _formatString(arg, Colors.FG_BLACK, false);
  
}
