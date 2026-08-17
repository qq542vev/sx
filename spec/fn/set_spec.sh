#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_fn_set'
	Include ./sx.sh

	It '関数を動的に定義すること'
		sx_fn_set "my_func=echo hello"
		result=$(my_func)
		The value "$result" should equal "hello"
	End

	It '複数の関数を定義すること'
		sx_fn_set "f1=echo 1" "f2=echo 2"
		The value "$(f1)" should equal "1"
		The value "$(f2)" should equal "2"
	End

	It '定義された関数内で位置パラメータを使用できること'
		sx_fn_set 'say=echo "Hello, $1"'
		The value "$(say World)" should equal "Hello, World"
	End

	It '無効な関数名に対して EX_USAGE (64) を返すこと'
		When call sx_fn_set "1invalid=echo fail"
		The status should equal 64
	End

	It '等号が欠如している場合に EX_USAGE (64) を返すこと'
		When call sx_fn_set "invalid_format"
		The status should equal 64
	End

	It '関数本体に構文エラーがある場合に EX_USAGE (64) を返すこと'
		# "if" without "fi" is a syntax error
		When call sx_fn_set "bad_fn=if :"
		The status should equal 64
	End

	It 'SX_CFG_SKIP_CHK が 1 の時にチェックをスキップすること'
		SX_CFG_SKIP_CHK=1 sx_fn_set "my_fast_fn=echo fast"
		The value "$(my_fast_fn)" should equal "fast"
	End
End
