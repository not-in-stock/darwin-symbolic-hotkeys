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

{ lib ? import <nixpkgs/lib> }:

let
  # Helper to create a key entry with both ASCII and keyCode
  mkKey = ascii: keyCode: { inherit ascii keyCode; };

  # For letters: ASCII is the lowercase letter code
  mkLetter = char: keyCode: mkKey char keyCode;

  # For non-letter keys: ASCII is 65535 (0xFFFF)
  mkSpecial = keyCode: mkKey 65535 keyCode;

  # Keys defined here, used to generate keyCodeNames
  keys = {
    # Letters (QWERTY layout) - ASCII is the lowercase letter code
    a = mkLetter 97 0;
    b = mkLetter 98 11;
    c = mkLetter 99 8;
    d = mkLetter 100 2;
    e = mkLetter 101 14;
    f = mkLetter 102 3;
    g = mkLetter 103 5;
    h = mkLetter 104 4;
    i = mkLetter 105 34;
    j = mkLetter 106 38;
    k = mkLetter 107 40;
    l = mkLetter 108 37;
    m = mkLetter 109 46;
    n = mkLetter 110 45;
    o = mkLetter 111 31;
    p = mkLetter 112 35;
    q = mkLetter 113 12;
    r = mkLetter 114 15;
    s = mkLetter 115 1;
    t = mkLetter 116 17;
    u = mkLetter 117 32;
    v = mkLetter 118 9;
    w = mkLetter 119 13;
    x = mkLetter 120 7;
    y = mkLetter 121 16;
    z = mkLetter 122 6;

    # Numbers (top row) - ASCII is 65535
    "0" = mkSpecial 29;
    "1" = mkSpecial 18;
    "2" = mkSpecial 19;
    "3" = mkSpecial 20;
    "4" = mkSpecial 21;
    "5" = mkSpecial 23;
    "6" = mkSpecial 22;
    "7" = mkSpecial 26;
    "8" = mkSpecial 28;
    "9" = mkSpecial 25;

    # Special keys
    space = mkKey 32 49; # Space has ASCII 32
    return = mkSpecial 36;
    enter = mkSpecial 36; # alias for return
    tab = mkSpecial 48;
    delete = mkSpecial 51;
    backspace = mkSpecial 51; # alias for delete
    escape = mkSpecial 53;
    esc = mkSpecial 53; # alias for escape
    none = mkKey 65535 65535; # No key

    # Punctuation
    minus = mkSpecial 27;
    equal = mkSpecial 24;
    equals = mkSpecial 24; # alias for equal
    leftBracket = mkSpecial 33;
    rightBracket = mkSpecial 30;
    backslash = mkSpecial 42;
    semicolon = mkSpecial 41;
    quote = mkSpecial 39;
    grave = mkSpecial 50;
    backtick = mkSpecial 50; # alias for grave
    comma = mkSpecial 43;
    period = mkSpecial 47;
    slash = mkSpecial 44;

    # Arrow keys
    left = mkSpecial 123;
    right = mkSpecial 124;
    down = mkSpecial 125;
    up = mkSpecial 126;

    # Function keys
    f1 = mkSpecial 122;
    f2 = mkSpecial 120;
    f3 = mkSpecial 99;
    f4 = mkSpecial 118;
    f5 = mkSpecial 96;
    f6 = mkSpecial 97;
    f7 = mkSpecial 98;
    f8 = mkSpecial 100;
    f9 = mkSpecial 101;
    f10 = mkSpecial 109;
    f11 = mkSpecial 103;
    f12 = mkSpecial 111;
    f13 = mkSpecial 105;
    f14 = mkSpecial 107;
    f15 = mkSpecial 113;
    f16 = mkSpecial 106;
    f17 = mkSpecial 64;
    f18 = mkSpecial 79;
    f19 = mkSpecial 80;
    f20 = mkSpecial 90;

    # Navigation keys
    home = mkSpecial 115;
    end = mkSpecial 119;
    pageUp = mkSpecial 116;
    pageDown = mkSpecial 121;

    # Other special keys
    forwardDelete = mkSpecial 117;
    help = mkSpecial 114;

    # Media keys (may vary)
    volumeUp = mkSpecial 72;
    volumeDown = mkSpecial 73;
    mute = mkSpecial 74;
  };

  # Generate reverse lookup from keys
  # Filters out aliases (keys with same keyCode) keeping first occurrence
  keyCodeNames = lib.foldlAttrs (
    acc: name: value:
    let
      code = toString value.keyCode;
    in
    if acc ? ${code} then acc else acc // { ${code} = name; }
  ) { } keys;

in
{
  inherit keys keyCodeNames;

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
}
