# macOS key codes and modifier values for symbolic hotkeys
#
# Key codes are virtual key codes used by macOS.
# Reference: https://eastmanreference.com/complete-list-of-applescript-key-codes
#
# Modifier values are bitmasks:
#   - Shift:   bit 17 (131072)
#   - Control: bit 18 (262144)
#   - Option:  bit 19 (524288)
#   - Command: bit 20 (1048576)
#   - Fn:      bit 23 (8388608)

{
  # Mapping table for characters to ASCII codes (lowercase)
  # Used for the first parameter in symbolic hotkey values
  asciiCodes = {
    a = 97;
    b = 98;
    c = 99;
    d = 100;
    e = 101;
    f = 102;
    g = 103;
    h = 104;
    i = 105;
    j = 106;
    k = 107;
    l = 108;
    m = 109;
    n = 110;
    o = 111;
    p = 112;
    q = 113;
    r = 114;
    s = 115;
    t = 116;
    u = 117;
    v = 118;
    w = 119;
    x = 120;
    y = 121;
    z = 122;

    # For digits and special characters use 65535 (0xFFFF)
    "0" = 65535;
    "1" = 65535;
    "2" = 65535;
    "3" = 65535;
    "4" = 65535;
    "5" = 65535;
    "6" = 65535;
    "7" = 65535;
    "8" = 65535;
    "9" = 65535;

    # Special keys also use 65535
    space = 32;
    none = 65535;
  };

  # Mapping table for characters to macOS virtual key codes
  # Used for the second parameter in symbolic hotkey values
  keyCodes = {
    # Letters (QWERTY layout)
    a = 0;
    s = 1;
    d = 2;
    f = 3;
    h = 4;
    g = 5;
    z = 6;
    x = 7;
    c = 8;
    v = 9;
    b = 11;
    q = 12;
    w = 13;
    e = 14;
    r = 15;
    y = 16;
    t = 17;
    o = 31;
    u = 32;
    i = 34;
    p = 35;
    l = 37;
    j = 38;
    k = 40;
    n = 45;
    m = 46;

    # Numbers (top row)
    "1" = 18;
    "2" = 19;
    "3" = 20;
    "4" = 21;
    "5" = 23;
    "6" = 22;
    "7" = 26;
    "8" = 28;
    "9" = 25;
    "0" = 29;

    # Special keys
    space = 49;
    return = 36;
    enter = 36;
    tab = 48;
    delete = 51;
    backspace = 51;
    escape = 53;
    esc = 53;

    # Punctuation
    minus = 27;
    equal = 24;
    equals = 24;
    leftBracket = 33;
    rightBracket = 30;
    backslash = 42;
    semicolon = 41;
    quote = 39;
    grave = 50;
    backtick = 50;
    comma = 43;
    period = 47;
    slash = 44;

    # Arrow keys
    left = 123;
    right = 124;
    down = 125;
    up = 126;

    # Function keys
    f1 = 122;
    f2 = 120;
    f3 = 99;
    f4 = 118;
    f5 = 96;
    f6 = 97;
    f7 = 98;
    f8 = 100;
    f9 = 101;
    f10 = 109;
    f11 = 103;
    f12 = 111;
    f13 = 105;
    f14 = 107;
    f15 = 113;
    f16 = 106;
    f17 = 64;
    f18 = 79;
    f19 = 80;
    f20 = 90;

    # Navigation keys
    home = 115;
    end = 119;
    pageUp = 116;
    pageDown = 121;

    # Other special keys
    forwardDelete = 117;
    help = 114;

    # Media keys (may vary)
    volumeUp = 72;
    volumeDown = 73;
    mute = 74;
  };

  # Modifier key values (bits 17-20, 23)
  # These can be combined by adding them together
  modifiers = {
    shift = 131072; # bit 17 (1 << 17)
    ctrl = 262144; # bit 18 (1 << 18)
    control = 262144; # alias for ctrl
    opt = 524288; # bit 19 (1 << 19)
    option = 524288; # alias for opt
    alt = 524288; # alias for opt
    cmd = 1048576; # bit 20 (1 << 20)
    command = 1048576; # alias for cmd
    fn = 8388608; # bit 23 (1 << 23)
    globe = 8388608; # alias for fn

    # Common combinations
    none = 0;
  };

  # Reverse lookup: keyCode -> key name (for debugging/display)
  keyCodeNames = {
    "0" = "a";
    "1" = "s";
    "2" = "d";
    "3" = "f";
    "4" = "h";
    "5" = "g";
    "6" = "z";
    "7" = "x";
    "8" = "c";
    "9" = "v";
    "11" = "b";
    "12" = "q";
    "13" = "w";
    "14" = "e";
    "15" = "r";
    "16" = "y";
    "17" = "t";
    "18" = "1";
    "19" = "2";
    "20" = "3";
    "21" = "4";
    "22" = "6";
    "23" = "5";
    "25" = "9";
    "26" = "7";
    "28" = "8";
    "29" = "0";
    "31" = "o";
    "32" = "u";
    "34" = "i";
    "35" = "p";
    "37" = "l";
    "38" = "j";
    "40" = "k";
    "45" = "n";
    "46" = "m";
    "49" = "space";
    "36" = "return";
    "48" = "tab";
    "51" = "delete";
    "53" = "escape";
    "123" = "left";
    "124" = "right";
    "125" = "down";
    "126" = "up";
    "122" = "f1";
    "120" = "f2";
    "99" = "f3";
    "118" = "f4";
    "96" = "f5";
    "97" = "f6";
    "98" = "f7";
    "100" = "f8";
    "101" = "f9";
    "109" = "f10";
    "103" = "f11";
    "111" = "f12";
  };
}
