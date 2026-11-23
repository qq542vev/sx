dnl 文字集合マクロ (M_STR_*)
define([|M_STR_SOH|], [|format([|%c|], 1)|])dnl
define([|M_STR_STX|], [|format([|%c|], 2)|])dnl
define([|M_STR_ETX|], [|format([|%c|], 3)|])dnl
define([|M_STR_EOT|], [|format([|%c|], 4)|])dnl
define([|M_STR_ENQ|], [|format([|%c|], 5)|])dnl
define([|M_STR_ACK|], [|format([|%c|], 6)|])dnl
define([|M_STR_BEL|], [|format([|%c|], 7)|])dnl
define([|M_STR_BS|], [|format([|%c|], 8)|])dnl
define([|M_STR_HT|], [|format([|%c|], 9)|])dnl
define([|M_STR_LF|], [|format([|%c|], 10)|])dnl
define([|M_STR_VT|], [|format([|%c|], 11)|])dnl
define([|M_STR_FF|], [|format([|%c|], 12)|])dnl
define([|M_STR_CR|], [|format([|%c|], 13)|])dnl
define([|M_STR_SO|], [|format([|%c|], 14)|])dnl
define([|M_STR_SI|], [|format([|%c|], 15)|])dnl
define([|M_STR_DLE|], [|format([|%c|], 16)|])dnl
define([|M_STR_DC1|], [|format([|%c|], 17)|])dnl
define([|M_STR_DC2|], [|format([|%c|], 18)|])dnl
define([|M_STR_DC3|], [|format([|%c|], 19)|])dnl
define([|M_STR_DC4|], [|format([|%c|], 20)|])dnl
define([|M_STR_NAK|], [|format([|%c|], 21)|])dnl
define([|M_STR_SYN|], [|format([|%c|], 22)|])dnl
define([|M_STR_ETB|], [|format([|%c|], 23)|])dnl
define([|M_STR_CAN|], [|format([|%c|], 24)|])dnl
define([|M_STR_EM|], [|format([|%c|], 25)|])dnl
define([|M_STR_SUB|], [|format([|%c|], 26)|])dnl
define([|M_STR_ESC|], [|format([|%c|], 27)|])dnl
define([|M_STR_FS|], [|format([|%c|], 28)|])dnl
define([|M_STR_GS|], [|format([|%c|], 29)|])dnl
define([|M_STR_RS|], [|format([|%c|], 30)|])dnl
define([|M_STR_US|], [|format([|%c|], 31)|])dnl
define([|M_STR_DEL|], [|format([|%c|], 127)|])dnl

define([|M_STR_BPH|], [|\x82|])dnl
define([|M_STR_NBH|], [|\x83|])dnl
define([|M_STR_NEL|], [|\x85|])dnl
define([|M_STR_SSA|], [|\x86|])dnl
define([|M_STR_ESA|], [|\x87|])dnl
define([|M_STR_HTS|], [|\x88|])dnl
define([|M_STR_HTJ|], [|\x89|])dnl
define([|M_STR_VTS|], [|\x8A|])dnl
define([|M_STR_PLD|], [|\x8B|])dnl
define([|M_STR_PLU|], [|\x8C|])dnl
define([|M_STR_RI|], [|\x8D|])dnl
define([|M_STR_SS2|], [|\x8E|])dnl
define([|M_STR_SS3|], [|\x8F|])dnl
define([|M_STR_DCS|], [|\x90|])dnl
define([|M_STR_PU1|], [|\x91|])dnl
define([|M_STR_PU2|], [|\x92|])dnl
define([|M_STR_STS|], [|\x93|])dnl
define([|M_STR_CCH|], [|\x94|])dnl
define([|M_STR_MW|], [|\x95|])dnl
define([|M_STR_SPA|], [|\x96|])dnl
define([|M_STR_EPA|], [|\x97|])dnl
define([|M_STR_SOS|], [|\x98|])dnl
define([|M_STR_SCI|], [|\x9A|])dnl
define([|M_STR_CSI|], [|\x9B|])dnl
define([|M_STR_ST|], [|\x9C|])dnl
define([|M_STR_OSC|], [|\x9D|])dnl
define([|M_STR_PM|], [|\x9E|])dnl
define([|M_STR_APC|], [|\x9F|])dnl

define([|M_STR_C1|], [|\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F|])dnl

define([|M_STR_GR|], [|\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF|])dnl

define([|M_STR_C1_ARGS|], [|$'\x80' $'\x81' $'\x82' $'\x83' $'\x84' $'\x85' $'\x86' $'\x87' $'\x88' $'\x89' $'\x8A' $'\x8B' $'\x8C' $'\x8D' $'\x8E' $'\x8F' $'\x90' $'\x91' $'\x92' $'\x93' $'\x94' $'\x95' $'\x96' $'\x97' $'\x98' $'\x99' $'\x9A' $'\x9B' $'\x9C' $'\x9D' $'\x9E' $'\x9F'|])dnl
define([|M_STR_GR_ARGS|], [|$'\xA0' $'\xA1' $'\xA2' $'\xA3' $'\xA4' $'\xA5' $'\xA6' $'\xA7' $'\xA8' $'\xA9' $'\xAA' $'\xAB' $'\xAC' $'\xAD' $'\xAE' $'\xAF' $'\xB0' $'\xB1' $'\xB2' $'\xB3' $'\xB4' $'\xB5' $'\xB6' $'\xB7' $'\xB8' $'\xB9' $'\xBA' $'\xBB' $'\xBC' $'\xBD' $'\xBE' $'\xBF' $'\xC0' $'\xC1' $'\xC2' $'\xC3' $'\xC4' $'\xC5' $'\xC6' $'\xC7' $'\xC8' $'\xC9' $'\xCA' $'\xCB' $'\xCC' $'\xCD' $'\xCE' $'\xCF' $'\xD0' $'\xD1' $'\xD2' $'\xD3' $'\xD4' $'\xD5' $'\xD6' $'\xD7' $'\xD8' $'\xD9' $'\xDA' $'\xDB' $'\xDC' $'\xDD' $'\xDE' $'\xDF' $'\xE0' $'\xE1' $'\xE2' $'\xE3' $'\xE4' $'\xE5' $'\xE6' $'\xE7' $'\xE8' $'\xE9' $'\xEA' $'\xEB' $'\xEC' $'\xED' $'\xEE' $'\xEF' $'\xF0' $'\xF1' $'\xF2' $'\xF3' $'\xF4' $'\xF5' $'\xF6' $'\xF7' $'\xF8' $'\xF9' $'\xFA' $'\xFB' $'\xFC' $'\xFD' $'\xFE' $'\xFF'|])dnl
define([|M_STR_BLANK|], [|M_STR_HT() |])dnl
define([|M_STR_BLANK_ARGS|], [|'M_STR_HT()' ' '|])dnl
define([|M_STR_SPACE|], [|M_STR_HT()M_STR_LF()M_STR_VT()M_STR_FF()M_STR_CR() |])dnl
define([|M_STR_SPACE_ARGS|], [|'M_STR_HT()' 'M_STR_LF()' 'M_STR_VT()' 'M_STR_FF()' 'M_STR_CR()' ' '|])dnl
define([|M_STR_C0|], [|M_STR_SOH()M_STR_STX()M_STR_ETX()M_STR_EOT()M_STR_ENQ()M_STR_ACK()M_STR_BEL()M_STR_BS()M_STR_HT()M_STR_LF()M_STR_VT()M_STR_FF()M_STR_CR()M_STR_SO()M_STR_SI()M_STR_DLE()M_STR_DC1()M_STR_DC2()M_STR_DC3()M_STR_DC4()M_STR_NAK()M_STR_SYN()M_STR_ETB()M_STR_CAN()M_STR_EM()M_STR_SUB()M_STR_ESC()M_STR_FS()M_STR_GS()M_STR_RS()M_STR_US()|])dnl
define([|M_STR_C0_ARGS|], [|'M_STR_SOH()' 'M_STR_STX()' 'M_STR_ETX()' 'M_STR_EOT()' 'M_STR_ENQ()' 'M_STR_ACK()' 'M_STR_BEL()' 'M_STR_BS()' 'M_STR_HT()' 'M_STR_LF()' 'M_STR_VT()' 'M_STR_FF()' 'M_STR_CR()' 'M_STR_SO()' 'M_STR_SI()' 'M_STR_DLE()' 'M_STR_DC1()' 'M_STR_DC2()' 'M_STR_DC3()' 'M_STR_DC4()' 'M_STR_NAK()' 'M_STR_SYN()' 'M_STR_ETB()' 'M_STR_CAN()' 'M_STR_EM()' 'M_STR_SUB()' 'M_STR_ESC()' 'M_STR_FS()' 'M_STR_GS()' 'M_STR_RS()' 'M_STR_US()'|])dnl
define([|M_STR_CNTRL|], [|M_STR_C0()M_STR_DEL()|])dnl
define([|M_STR_CNTRL_ARGS|], [|M_STR_C0_ARGS() 'M_STR_DEL()'|])dnl
define([|M_STR_CONTROL|], [|M_STR_CNTRL()M_STR_C1()|])dnl
define([|M_STR_CONTROL_ARGS|], [|M_STR_CNTRL_ARGS() M_STR_C1_ARGS()|])dnl
define([|M_STR_BIN|], [|01|])dnl
define([|M_STR_BIN_ARGS|], [|'0' '1'|])dnl
define([|M_STR_OCT|], [|01234567|])dnl
define([|M_STR_OCT_ARGS|], [|'0' '1' '2' '3' '4' '5' '6' '7'|])dnl
define([|M_STR_DIGIT|], [|0123456789|])dnl
define([|M_STR_DIGIT_ARGS|], [|'0' '1' '2' '3' '4' '5' '6' '7' '8' '9'|])dnl
define([|M_STR_XDIGIT|], [|0123456789ABCDEFabcdef|])dnl
define([|M_STR_XDIGIT_ARGS|], [|'0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'A' 'B' 'C' 'D' 'E' 'F' 'a' 'b' 'c' 'd' 'e' 'f'|])dnl
define([|M_STR_UPPER|], [|ABCDEFGHIJKLMNOPQRSTUVWXYZ|])dnl
define([|M_STR_UPPER_ARGS|], [|[|'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z'|]|])dnl
define([|M_STR_LOWER|], [|abcdefghijklmnopqrstuvwxyz|])dnl
define([|M_STR_LOWER_ARGS|], [|[|'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z'|]|])dnl
define([|M_STR_PUNCT|], [|[|!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~|]|])dnl
define([|M_STR_PUNCT_ARGS|], [|[|'!' '"' '#' '$' '%' '&' "'" '(' ')' '*' '+' ',' '-' '.' '/' ':' ';' '<' '=' '>' '?' '@' '[' '\' ']' '^' '_' '`' '{' '|' '}' '~'|]|])dnl
define([|M_STR_ALPHA|], [|M_STR_UPPER()[||]M_STR_LOWER()|])dnl
define([|M_STR_ALPHA_ARGS|], [|M_STR_UPPER_ARGS() M_STR_LOWER_ARGS()|])dnl
define([|M_STR_ALNUM|], [|M_STR_DIGIT()M_STR_ALPHA()|])dnl
define([|M_STR_ALNUM_ARGS|], [|M_STR_DIGIT_ARGS() M_STR_ALPHA_ARGS()|])dnl
define([|M_STR_WORD|], [|M_STR_DIGIT()M_STR_UPPER()_[||]M_STR_LOWER()|])dnl
define([|M_STR_WORD_ARGS|], [|M_STR_DIGIT_ARGS() M_STR_UPPER_ARGS() '_' M_STR_LOWER_ARGS()|])dnl
define([|M_STR_ALUND|], [|M_STR_UPPER()_[||]M_STR_LOWER()|])dnl
define([|M_STR_ALUND_ARGS|], [|M_STR_UPPER_ARGS() '_' M_STR_LOWER_ARGS()|])dnl
define([|M_STR_GRAPH|], [|[|!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~|]|])dnl
define([|M_STR_GRAPH_ARGS|], [|[|'!' '"' '#' '$' '%' '&' "'" '(' ')' '*' '+' ',' '-' '.' '/' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' ':' ';' '<' '=' '>' '?' '@' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' '[' '\' ']' '^' '_' '`' 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' '{' '|' '}' '~'|]|])dnl
define([|M_STR_GRAPHIC|], [|M_SH_ESCAPE(M_STR_GRAPH)[||]M_STR_GR()|])dnl
define([|M_STR_GRAPHIC_ARGS|], [|M_STR_GRAPH_ARGS() M_STR_GR_ARGS()|])dnl
define([|M_STR_PRINT|], [| M_STR_GRAPH()|])dnl
define([|M_STR_PRINT_ARGS|], [|' ' M_STR_GRAPH_ARGS()|])dnl
define([|M_STR_PRINTABLE|], [|M_SH_ESCAPE(M_STR_PRINT)[||]M_STR_GR()|])dnl
define([|M_STR_PRINTABLE_ARGS|], [|M_STR_PRINT_ARGS() M_STR_GR_ARGS()|])dnl
define([|M_STR_ASCII|], [|M_STR_C0()M_STR_PRINT()M_STR_DEL()|])dnl
define([|M_STR_ASCII_ARGS|], [|M_STR_C0_ARGS() M_STR_PRINT_ARGS() 'M_STR_DEL()'|])dnl
define([|M_STR_NONASCII|], [|\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF|])dnl

define([|M_STR_NONASCII_ARGS|], [|M_STR_C1_ARGS() M_STR_GR_ARGS()|])dnl

define([|M_STR_BYTE|], [|M_SH_ESCAPE(M_STR_ASCII)[||]M_STR_NONASCII()|])dnl
define([|M_STR_BYTE_ARGS|], [|M_STR_ASCII_ARGS() M_STR_NONASCII_ARGS()|])dnl

define([|__sx_m4_gen_byte|], [|define(format([|[|M_STR_B%02X|]|], $1), ifelse($1, 91, [|format([|format([|%%c|], %d)|], $1)|], eval($1 < 128), 1, [|format([|[|[|%c|]|]|], $1)|], [|format([|[|[|\x%02X|]|]|], $1)|]))dnl
ifelse($1, 255, [||], [|__sx_m4_gen_byte(incr($1))|])|])dnl
__sx_m4_gen_byte(1)dnl

define([|M_STR_SPLIT_GLOB|], [|1|])dnl
define([|M_STR_SPLIT_INC|], [|2|])dnl
define([|M_STR_SPLIT_ICASE|], [|4|])dnl
define([|M_STR_SPLIT_EQ|], [|8|])dnl
define([|M_STR_SUB_GLOB|], [|1|])dnl
define([|M_STR_SUB_CB|], [|2|])dnl
define([|M_STR_CAPITAL_KEEP|], [|1|])dnl
define([|M_STR_CAPITAL_SENT|], [|2|])dnl
define([|M_STR_ISEP_CB|], [|1|])dnl
define([|M_STR_ISEP_PRE|], [|2|])dnl
define([|M_STR_ISEP_POST|], [|4|])dnl
define([|M_STR_FIND_GLOB|], [|1|])dnl
define([|M_STR_FIND_OVERLAP|], [|2|])dnl
define([|M_STR_FIND_TEXT|], [|4|])dnl
define([|M_STR_FIND_POS|], [|8|])dnl
define([|M_STR_FIND_LEN|], [|16|])dnl
define([|M_STR_FIND_ICASE|], [|32|])dnl
define([|M_STR_FIND_EQC|], [|64|])dnl
define([|M_STR_RFIND_GLOB|], [|1|])dnl
define([|M_STR_RFIND_OVERLAP|], [|2|])dnl
define([|M_STR_RFIND_TEXT|], [|4|])dnl
define([|M_STR_RFIND_POS|], [|8|])dnl
define([|M_STR_RFIND_LEN|], [|16|])dnl
define([|M_STR_RFIND_ICASE|], [|32|])dnl
define([|M_STR_RFIND_EQC|], [|64|])dnl
define([|M_STR_COUNT_GLOB|], [|1|])dnl
define([|M_STR_COUNT_OVERLAP|], [|2|])dnl
define([|M_STR_COUNT_ICASE|], [|32|])dnl
define([|M_STR_COUNT_EQC|], [|64|])dnl
define([|M_STR_CHUNK_SKIP_SHORT|], [|1|])dnl
define([|M_STR_CHUNK_SKIP_LONG|], [|2|])dnl
define([|M_STR_RCHUNK_SKIP_SHORT|], [|1|])dnl
define([|M_STR_RCHUNK_SKIP_LONG|], [|2|])dnl
