M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_upper_cb - sx_str_upper 用コールバック（内部用）
##
## 使い方:
##   __sx_str_upper_cb 結果変数名 マッチ文字列 left right count
##
## 説明:
##   sx_str_sub のコールバックモードから呼び出される。
##   マッチした小文字1文字を大文字に変換して結果変数に格納する。
__sx_str_upper_cb() {
	case "${2}" in
		a) eval "${1}=A";; b) eval "${1}=B";;
		c) eval "${1}=C";; d) eval "${1}=D";;
		e) eval "${1}=E";; f) eval "${1}=F";;
		g) eval "${1}=G";; h) eval "${1}=H";;
		i) eval "${1}=I";; j) eval "${1}=J";;
		k) eval "${1}=K";; l) eval "${1}=L";;
		m) eval "${1}=M";; n) eval "${1}=N";;
		o) eval "${1}=O";; p) eval "${1}=P";;
		q) eval "${1}=Q";; r) eval "${1}=R";;
		s) eval "${1}=S";; t) eval "${1}=T";;
		u) eval "${1}=U";; v) eval "${1}=V";;
		w) eval "${1}=W";; x) eval "${1}=X";;
		y) eval "${1}=Y";; z) eval "${1}=Z";;
		*) eval "${1}=\"\${2}\"";;
	esac
}

popdef([|CLEANUP|])dnl
