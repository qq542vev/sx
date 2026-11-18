dnl URI 文字集合マクロ (M_URI_*)
define([|M_URI_UNRESERVED|], [|[|-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~|]|])dnl
define([|M_URI_UNRESERVED_ARGS|], [|[|'-' '.' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' '_' 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' '~'|]|])dnl
define([|M_URI_GEN_DELIMS|], [|[|#/:?@[]|]|])dnl
define([|M_URI_GEN_DELIMS_ARGS|], [|[|'#' '/' ':' '?' '@' '[' ']'|]|])dnl
define([|M_URI_SUB_DELIMS|], [|[|!$&'()*+,;=|]|])dnl
define([|M_URI_SUB_DELIMS_ARGS|], [|[|'!' '$' '&' "'" '(' ')' '*' '+' ',' ';' '='|]|])dnl
define([|M_URI_RESERVED|], [|[|!#$&'()*+,/:;=?@[]|]|])dnl
define([|M_URI_RESERVED_ARGS|], [|[|'!' '#' '$' '&' "'" '(' ')' '*' '+' ',' '/' ':' ';' '=' '?' '@' '[' ']'|]|])dnl
define([|M_URI_PCHAR|], [|[|!$&'()*+,-.0123456789:;=@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~|]|])dnl
define([|M_URI_PCHAR_ARGS|], [|[|'!' '$' '&' "'" '(' ')' '*' '+' ',' '-' '.' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' ':' ';' '=' '@' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' '_' 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' '~'|]|])dnl
define([|M_URI_USERINFO|], [|[|!$&'()*+,-.0123456789:;=ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~|]|])dnl
define([|M_URI_USERINFO_ARGS|], [|[|'!' '$' '&' "'" '(' ')' '*' '+' ',' '-' '.' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' ':' ';' '=' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' '_' 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' '~'|]|])dnl
define([|M_URI_REG_NAME|], [|[|!$&'()*+,-.0123456789;=ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~|]|])dnl
define([|M_URI_REG_NAME_ARGS|], [|[|'!' '$' '&' "'" '(' ')' '*' '+' ',' '-' '.' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' ';' '=' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' '_' 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' '~'|]|])dnl
define([|M_URI_PORT|], [|M_STR_DIGIT()|])dnl
define([|M_URI_PORT_ARGS|], [|M_STR_DIGIT_ARGS()|])dnl
define([|M_URI_HEXDIG|], [|M_STR_XDIGIT()|])dnl
define([|M_URI_HEXDIG_ARGS|], [|M_STR_XDIGIT_ARGS()|])dnl
define([|M_URI_SEGMENT_NZ_NC|], [|[|!$&'()*+,-.0123456789;=@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~|]|])dnl
define([|M_URI_SEGMENT_NZ_NC_ARGS|], [|[|'!' '$' '&' "'" '(' ')' '*' '+' ',' '-' '.' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' ';' '=' '@' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' '_' 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' '~'|]|])dnl
define([|M_URI_QUERY|], [|[|!$&'()*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~|]|])dnl
define([|M_URI_QUERY_ARGS|], [|[|'!' '$' '&' "'" '(' ')' '*' '+' ',' '-' '.' '/' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' ':' ';' '=' '?' '@' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' '_' 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' '~'|]|])dnl
define([|M_URI_FRAGMENT|], [|[|!$&'()*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~|]|])dnl
define([|M_URI_FRAGMENT_ARGS|], [|[|'!' '$' '&' "'" '(' ')' '*' '+' ',' '-' '.' '/' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' ':' ';' '=' '?' '@' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' '_' 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' '~'|]|])dnl
define([|M_URI_SCHEME|], [|[|+-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz|]|])dnl
define([|M_URI_SCHEME_ARGS|], [|[|'+' '-' '.' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z'|]|])dnl
define([|M_URI_SCHEME_FIRST|], [|[|ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz|]|])dnl
define([|M_URI_SCHEME_FIRST_ARGS|], [|[|'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z'|]|])dnl
define([|M_URI_ACCEPT_PCT_ENCODED|], [|%[M_STR_XDIGIT()][M_STR_XDIGIT()]|])dnl

__sx_m4_gen_uri_enc_case(1)dnl
