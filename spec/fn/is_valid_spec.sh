#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_fn_is_valid'
	Include ./sx.sh

	It '有効な定義に対して 0 を返すこと'
		When call sx_fn_is_valid "f=:" "g=echo hello"
		The status should be success
	End

	It '空の関数本体に対して 0 を返すこと'
		When call sx_fn_is_valid "f="
		The status should be success
	End

	It '複雑な関数本体に対して 0 を返すこと'
		When call sx_fn_is_valid "f={ echo a | cat; } > /dev/null"
		The status should be success
	End

	It '無効な関数名に対して 1 を返すこと'
		When call sx_fn_is_valid "123f=:"
		The status should be failure
	End

	It '等号が欠如している場合に 1 を返すこと'
		When call sx_fn_is_valid "invalid"
		The status should be failure
	End

	It '関数本体に構文エラーがある場合に 1 を返すこと'
		# "if" without "fi" is a syntax error
		When call sx_fn_is_valid "bad=if :"
		The status should be failure
	End

	It 'いずれかの定義が無効な場合に 1 を返すこと'
		When call sx_fn_is_valid "f=:" "123g=:"
		The status should be failure
	End

	It '関数をグローバルに定義しないこと'
		sx_fn_is_valid "should_not_exist=echo exist"
		When call should_not_exist
		The status should equal 127
		The stderr should include "should_not_exist"
	End
End
