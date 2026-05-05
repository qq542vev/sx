#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_len'
	Include ./sx.sh

	xIt '単一の引数（集約モード）'
		When call sx_str_len res "abc"
		The variable res should eq "3"
	End

	xIt '複数の引数（集約モード）'
		When call sx_str_len res "abc" "de" "fghij"
		The variable res should eq "3 2 5"
	End

	xIt '空文字列の長さ'
		When call sx_str_len res "" " "
		The variable res should eq "0 1"
	End

	xIt '代入モード (var=val)'
		sx_str_len v1="hello" v2="world!"
		Assert [ "$v1" = "5" ]
		Assert [ "$v2" = "6" ]
	End

	xIt '混合代入モード'
		sx_str_len v1="" v2=" " v3="abc"
		Assert [ "$v1" = "0" ]
		Assert [ "$v2" = "1" ]
		Assert [ "$v3" = "3" ]
	End

	xIt 'LC_ALL=C (バイト数カウント)'
		# 3バイト文字
		str='あ'
		When call eval "LC_ALL=C sx_str_len res \"$str\""
		The variable res should eq "3"
	End

	xIt '無効な結果変数名に対してエラーを返すこと'
		When call sx_str_len "1invalid" "abc"
		The status should eq "$SX_EX_USAGE"
	End

	# Note: ShellSpec の環境によっては readonly のテストが難しい場合がありますが
	# shcore の標準的なテスト方法に準じます。
	xIt '読み取り専用変数に対してエラーを返すこと'
		readonly ro_var=0
		When call sx_str_len ro_var="abc"
		The status should eq "$SX_EX_NOPERM"
	End
End
