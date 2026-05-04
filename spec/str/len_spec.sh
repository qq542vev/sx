#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_len'
	Include ./sx.sh

	It 'single argument (aggregator mode)'
		When call sx_str_len res "abc"
		The variable res should eq "3"
	End

	It 'multiple arguments (aggregator mode)'
		When call sx_str_len res "abc" "de" "fghij"
		The variable res should eq "3 2 5"
	End

	It 'empty string length'
		When call sx_str_len res "" " "
		The variable res should eq "0 1"
	End

	It 'assignment mode (var=val)'
		sx_str_len v1="hello" v2="world!"
		Assert [ "$v1" = "5" ]
		Assert [ "$v2" = "6" ]
	End

	It 'mixed assignment mode'
		sx_str_len v1="" v2=" " v3="abc"
		Assert [ "$v1" = "0" ]
		Assert [ "$v2" = "1" ]
		Assert [ "$v3" = "3" ]
	End

	It 'LC_ALL=C (byte count)'
		# 3バイト文字
		str='あ'
		When call eval "LC_ALL=C sx_str_len res \"$str\""
		The variable res should eq "3"
	End

	It 'error on invalid result variable name'
		When call sx_str_len "1invalid" "abc"
		The status should eq "$SX_EX_USAGE"
	End

	# Note: ShellSpec の環境によっては readonly のテストが難しい場合がありますが
	# shcore の標準的なテスト方法に準じます。
	It 'error on readonly variable'
		readonly ro_var=0
		When call sx_str_len ro_var="abc"
		The status should eq "$SX_EX_NOPERM"
	End
End
