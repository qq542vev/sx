#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_find'
	Include ./sx.sh

	Context '単純一致'
		It '末尾の一致を検索すること'
			When call sx_str_find res "hello world" "world"
			The variable res should equal "6:5"
			The status should be success
		End

		It '先頭の一致を検索すること'
			When call sx_str_find res "abc" "a"
			The variable res should equal "0:1"
			The status should be success
		End

		It '中央の一致を検索すること'
			When call sx_str_find res "abc_def_ghi" "_def_"
			The variable res should equal "3:5"
			The status should be success
		End
	End

	Context '複数一致'
		It '複数の一致をスペース区切りで返すこと'
			When call sx_str_find res "ab_cd_ef" "_"
			The variable res should equal "2:1 5:1"
			The status should be success
		End

		It '隣接する一致を検索すること'
			When call sx_str_find res "a__b" "__"
			The variable res should equal "1:2"
			The status should be success
		End

		It '連続する一文字一致を検索すること'
			When call sx_str_find res "a_b_c" "_"
			The variable res should equal "1:1 3:1"
			The status should be success
		End
	End

	Context '不一致'
		It '一致しない場合に空文字列を返すこと'
			When call sx_str_find res "abc" "x"
			The variable res should equal ""
			The status should be failure
		End

		It '空の元文字列で検索する場合に失敗を返すこと'
			When call sx_str_find res "" "a"
			The variable res should equal ""
			The status should be failure
		End
	End

	Context '空文字列'
		It '空の検索文字列で全位置に長さ0を返すこと'
			When call sx_str_find res "abc" ""
			The variable res should equal "0:0 1:0 2:0"
			The status should be success
		End

		It '空の検索文字列と空の元文字列で位置0に長さ0を返すこと'
			When call sx_str_find res "" ""
			The variable res should equal "0:0"
			The status should be success
		End
	End

	Context 'エラーハンドリング'
		It '無効な結果変数名に対してエラーを返すこと'
			When call sx_str_find "1invalid" "abc" "a"
			The status should equal "$SX_EX_USAGE"
		End

		It '読み取り専用変数に対してエラーを返すこと'
			readonly ro_find_var=0
			When call sx_str_find ro_find_var "abc" "a"
			The status should equal "$SX_EX_NOPERM"
		End
	End
End
