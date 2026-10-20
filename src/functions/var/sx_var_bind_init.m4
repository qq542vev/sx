dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_var_bind_init __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_bind_init - バインド形式に基づき変数を初期化する
##
## 使い方:
##   sx_var_bind_init [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   指定されたバインド形式に従って、変数を初期化する。
##   通常の変数は削除（unset）され、数値プレフィックス（N名前）付きの変数は
##   空文字列（''）で初期化される。最後の変数も空文字列（''）で初期化される。
##   これにより、通常の変数が「省略された」ことを sx_var_is_set で判定でき、
##   蓄積スロット（数値プレフィックス付き・最後の変数）は bind が到達しなかった
##   場合でも「0 個のリスト」として常に参照可能（eval set -- "${v}" 等が安全）である。
##   対象が sx 配列である場合は、その関連要素（_len, _n 等）も含めて削除される。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  バインド形式が不正 (SX_EX_USAGE)
##   77  書き込み不可な変数が含まれる (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_var_bind_init() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_bind_init "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${@}" || return M_EX_USAGE

	__sx_var_is_bindable "${@}" || return M_EX_NOPERM

	__sx_var_bind_init "${@}"
}

popdef([|CLEANUP|])dnl
