dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_lower_cb - sx_str_lower 用コールバック（内部用）
##
## 使い方:
##   __sx_str_lower_cb 結果変数名 マッチ文字列 left right count
##
## 説明:
##   sx_str_sub のコールバックモードから呼び出される。
##   マッチした大文字1文字を小文字に変換して結果変数に格納する。
__sx_str_lower_cb() {
	case "${2}" in
		A) eval "${1}=a";; B) eval "${1}=b";;
		C) eval "${1}=c";; D) eval "${1}=d";;
		E) eval "${1}=e";; F) eval "${1}=f";;
		G) eval "${1}=g";; H) eval "${1}=h";;
		I) eval "${1}=i";; J) eval "${1}=j";;
		K) eval "${1}=k";; L) eval "${1}=l";;
		M) eval "${1}=m";; N) eval "${1}=n";;
		O) eval "${1}=o";; P) eval "${1}=p";;
		Q) eval "${1}=q";; R) eval "${1}=r";;
		S) eval "${1}=s";; T) eval "${1}=t";;
		U) eval "${1}=u";; V) eval "${1}=v";;
		W) eval "${1}=w";; X) eval "${1}=x";;
		Y) eval "${1}=y";; Z) eval "${1}=z";;
		*) eval "${1}=\"\${2}\"";;
	esac
}

popdef([|CLEANUP|])dnl
