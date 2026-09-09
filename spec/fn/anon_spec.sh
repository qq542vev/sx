#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_fn_anon'
	Include ./sx.sh

	It 'ユニークな関数名を生成して定義すること'
		sx_fn_anon f_name 'echo "hello"'
		The value "$(eval "${f_name}")" should equal "hello"
	End

	It '複数の関数を生成すること'
		sx_fn_anon "f1:f2" 'echo "one"' 'echo "two"'
		The value "$(eval "${f1}")" should equal "one"
		The value "$(eval "${f2}")" should equal "two"
	End

	It 'バインド変数に生成された関数名を返すこと'
		sx_fn_anon names 'echo 1' 'echo 2'
		The value "${names}" should match pattern 'sx_fn_anon_[0-9]* sx_fn_anon_[0-9]*'
	End

	It 'Nname: 形式で複数の関数名を1つの変数に集約すること'
		sx_fn_anon "2names:" 'echo 1' 'echo 2' 'echo 3'
		The value "${names}" should match pattern 'sx_fn_anon_[0-9]* sx_fn_anon_[0-9]*'
	End

	It 'Nname:name 形式で件数分と残りを別の変数に格納すること'
		sx_fn_anon "2f1:f2" 'echo 1' 'echo 2' 'echo 3'
		The value "${f1}" should match pattern 'sx_fn_anon_[0-9]* sx_fn_anon_[0-9]*'
		The value "${f2}" should match pattern 'sx_fn_anon_[0-9]*'
	End

	It '不正な関数本体に対して EX_USAGE (64) を返すこと'
		When call sx_fn_anon f_name 'if'
		The status should equal 64
	End
End
