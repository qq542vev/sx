dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_var_is_ebind sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_ebind - 文字列が拡張バインド形式として有効か確認する
##
## 使い方:
##   sx_var_is_ebind [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、拡張バインド形式として有効であるかを確認する。
##   vn を変数名、nat1 を [1-9][0-9]*、nat0 を 0|nat1、M を nat0、N を nat1 とし、
##   seg を M/vn | M/Nvn | M/ | M/N | vn | 空 | M/@vn | M/N@vn、
##   ebind を seg(:seg)* とする。N が存在する場合は M<N が必須である。
##   素 vn は scalar、M/vn・M/Nvn は list、
##   M/@vn・M/N@vn は arr、空・M/・M/N は型なしとなる。
##   異なる型で同名の変数を2回以上利用するのはエラー（sx_var_is_bind と同様）。
##   数値に上限はない（SX_CFG_NUM_RANGE は設定の妥当性チェックにのみ使用される）。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_var_is_ebind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_ebind "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_ebind "${@}"
}

popdef([|CLEANUP|])dnl
