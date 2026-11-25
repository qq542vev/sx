dnl シェル構文のパターン列 (M_SH_*)
dnl REJECT を先に評価し、通過後に ACCEPT を評価する。
dnl ACCEPT は REJECT 通過後（非WORDなし・数字始まりは数字のみ）を前提とする。
dnl SX_SH_PARAM_REJECT / SX_SH_PARAM_ACCEPT も同じ定義から生成する。
define([|M_SH_PARAM_REJECT|], [|[0-9]*[!0-9]*|?*[!M_STR_WORD()]*|])dnl
dnl ACCEPT のブラケットは内側をクォートし、! の否定・- の範囲・$ の展開を無効化する。
dnl m4 の $* 展開を避けるため $ は末尾に置く。
define([|M_SH_PARAM_ACCEPT|], [|['!#*-0?@$']|0*[1-9]*| [1-9M_STR_ALUND()]*|])dnl
dnl 位置パラメータは数字のみで、1 つ以上の 1-9 を含むものだけを受理する。
dnl REJECT だけでは全て 0 の文字列を拒否できないため、ACCEPT と組み合わせる。
define([|M_SH_REJECT_POS|], [|*[!0-9]*|])dnl
define([|M_SH_ACCEPT_POS|], [|*[1-9]*|])dnl
