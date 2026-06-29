#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_escape'
	Include ./sx.sh

	It 'デフォルト(\)で \" と \ をエスケープする'
		When call sx_str_escape res 'a\b"c' '\"'
		The variable res should eq 'a\\b\"c'
	End

	It '空文字列を入力すると空文字列を返す'
		When call sx_str_escape res '' '\'
		The variable res should eq ''
	End

	It 'エスケープ対象が含まれない場合は元の文字列をそのまま返す'
		When call sx_str_escape res 'abc' '\'
		The variable res should eq 'abc'
	End

	It 'エスケープ対象文字集合が空の場合は元の文字列をそのまま返す'
		When call sx_str_escape res 'a*b' ''
		The variable res should eq 'a*b'
	End

	It 'glob quoting: se=[, ee=] で *?[ をエスケープする'
		When call sx_str_escape res 'a*b?c[d' '*?[' '[' ']'
		The variable res should eq 'a[*]b[?]c[[]d'
	End

	It "SQL LIKE: se=', ee=' で ' をエスケープする"
		When call sx_str_escape res "a'b" "'" "'" "'"
		The variable res should eq "a'''b"
	End

	It 'HTML entities: se=&, ee=; で <>& をエスケープする'
		When call sx_str_escape res 'a<b&c' '<>&' '&' ';'
		The variable res should eq 'a&<;b&&;c'
	End

	It '複数の特殊文字をブラケットエスケープする'
		When call sx_str_escape res '*?[]' '*?[]' '[' ']'
		The variable res should eq '[*][?][[][]]'
	End

	It '連続して呼び出しても前回の影響を受けない'
		sx_str_escape res1 'a*b' '*?[' '[' ']'
		sx_str_escape res2 'x?y' '*?[' '[' ']'
		Assert [ "${res1}" = 'a[*]b' ]
		Assert [ "${res2}" = 'x[?]y' ]
	End

	It '無効な結果変数名に対してエラーを返す'
		When call sx_str_escape "1invalid" "abc"
		The status should eq "$SX_EX_USAGE"
	End

	It '読み取り専用変数に対してエラーを返す'
		readonly ro_var_escape=0
		When call sx_str_escape ro_var_escape "abc"
		The status should eq "$SX_EX_NOPERM"
	End

	It 'すべての引数を省略した場合、空文字列を返す'
		When call sx_str_escape res
		The variable res should eq ''
	End
End
