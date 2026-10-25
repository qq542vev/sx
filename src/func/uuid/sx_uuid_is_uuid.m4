M_REQUIRE([|__sx_uuid_is_uuid|])dnl
### sx_uuid_is_uuid - すべての引数が UUID 形式であるか確認する
##
## 使い方:
##   sx_uuid_is_uuid [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_uuid_is_uuid に委譲する。
##   引数で指定されたすべての文字列が、標準的な UUID 形式（8-4-4-4-12 の 16 進数）
##   であるかを確認する。大文字と小文字は区別しない。
##
## 終了ステータス:
##    0  すべて UUID 形式である (SX_EX_OK)
##    1  UUID 形式ではない文字列が含まれる

sx_uuid_is_uuid() {
	M_CFG_CHECK([|sx_uuid_is_uuid|])

	__sx_uuid_is_uuid "${@}" || return
}
