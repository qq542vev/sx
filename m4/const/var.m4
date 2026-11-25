dnl 変数名判定用のパターン列 (M_VAR_*)
dnl REJECT は空文字・数字始まり・WORD 外文字を含む値を拒否する。
define([|M_VAR_REJECT_NAME|], [|''|[0-9]*|*[!"M_STR_WORD()"]*|])dnl
