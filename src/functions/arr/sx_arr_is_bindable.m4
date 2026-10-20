dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_arr_is_bind __sx_arr_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_arr_is_bindable - バインド形式が有効であり、かつ配列を含む全変数が書き込み可能か確認する
##
## 使い方:
##   sx_arr_is_bindable [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   指定されたバインド形式が妥当な名前で構成されており、かつ含まれるすべての変数
##   （配列の _len を含む）が書き込み可能（読み取り専用でない）であることを確認する。
##   数値プレフィックス（N名前）を含むセグメントは配列とみなし、
##   name_len の書き込み可否も検査する。
##   最終セグメントは「残り全て」として配列扱いし、name_len の検査を行う。
##   `@` を含む形式は配列分配用として無効である（sx_arr_is_bind 参照）。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  書き込み不可な変数が含まれる (SX_EX_NOPERM)
##   64  バインド形式が不正 (SX_EX_USAGE)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arr_is_bindable() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_is_bindable "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_arr_is_bind "${@}" || return M_EX_USAGE

	__sx_arr_is_bindable "${@}"
}

popdef([|CLEANUP|])dnl
