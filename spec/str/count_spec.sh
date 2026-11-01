#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_count'
	sxtest_load ./build/modules/sx_str_count.sh

	It '単一一致で1を返すこと'
		When call sx_str_count res "hello world" "world"
		The status should be success
		The variable res should equal 1
	End

	It '複数一致を正しくカウントすること'
		When call sx_str_count res "ab_cd_ef" "_"
		The status should be success
		The variable res should equal 2
	End

	It '重複なしかつ隣接一致を正しくカウントすること'
		When call sx_str_count res "a__bc" "__"
		The status should be success
		The variable res should equal 1
	End

	It '空needleは文字数+1を返すこと'
		When call sx_str_count res "abc" ""
		The status should be success
		The variable res should equal 4
	End

	It '空文字列に空needleで1を返すこと'
		When call sx_str_count res "" ""
		The status should be success
		The variable res should equal 1
	End

	It '空文字列に非空needleで0を返すこと'
		When call sx_str_count res "" "a"
		The status should be success
		The variable res should equal 0
	End

	It '不一致で0・終了ステータス0を返すこと'
		When call sx_str_count res "abc" "x"
		The status should be success
		The variable res should equal 0
	End

	It '読み取り専用変数でエラーになること'
		readonly ro_var=0
		When call sx_str_count ro_var "abc" "a"
		The status should eq 77
	End

	It '重複フラグ有効で重なり合う一致をカウントすること'
		When call sx_str_count res "aaa" "aa" 2
		The status should be success
		The variable res should equal 2
	End

	It '重複フラグ無効で従来の動作を維持すること'
		When call sx_str_count res "aaa" "aa" 0
		The status should be success
		The variable res should equal 1
	End

	It '重複フラグ有効で複数重複一致をカウントすること'
		When call sx_str_count res "ababa" "aba" 2
		The status should be success
		The variable res should equal 2
	End

	It 'globモードでワイルドカード * が機能すること'
		When call sx_str_count res "hello world" "w*" 1
		The status should be success
		The variable res should equal 1
	End

	It 'globモードで複数一致をカウントすること'
		When call sx_str_count res "aXbXc" "X*" 1
		The status should be success
		The variable res should equal 2
	End

	It 'globモードで重複フラグと組み合わせられること'
		When call sx_str_count res "aaa" "a*" "$((1 | 2))"
		The status should be success
		The variable res should equal 3
	End

	It 'globモードで * 単体が空needle相当になること'
		When call sx_str_count res "abc" "*" 1
		The status should be success
		The variable res should equal 4
	End

	Context '空検索とアスタリスクのみの検索'
		Parameters
			'' 0 7
			'' 1 7
			'' 2 7
			'' 3 7
			'' 4 7
			'' 5 7
			'' 6 7
			'' 7 7
			'*' 1 7
			'*' 3 7
			'*' 5 7
			'*' 7 7
			'***' 1 7
			'***' 3 7
			'***' 5 7
			'***' 7 7
			'*' 0 3
			'*' 2 3
			'*' 4 3
			'*' 6 3
			'**' 0 1
			'***' 0 0
		End

		It 'フラグに従って境界またはリテラルの出現回数を返すこと'
			When call sx_str_count res 'a*b**c' "$1" "$2"
			The status should be success
			The variable res should equal "$3"
		End
	End

	It '空入力で複数のアスタリスクだけのglobを検索すると1を返すこと'
		When call sx_str_count res '' '***' 7
		The status should be success
		The variable res should equal 1
	End

	It '多バイト文字の空検索でも文字数に基づく境界数を返すこと'
		When call sx_str_count res 'あいう' ''
		The status should be success
		The variable res should equal 4
	End

	It '元文字列と検索文字列の省略時に1を返すこと'
		When call sx_str_count res
		The status should be success
		The variable res should equal 1
	End

	It 'globモードで一致なしは0を返すこと'
		When call sx_str_count res "abc" "x*" 1
		The status should be success
		The variable res should equal 0
	End

	It 'TEXTフラグがカウントに影響しないこと'
		When call sx_str_count res "a_b_c" "_" 4
		The status should be success
		The variable res should equal 2
	End

	It 'TEXT+glob+overlap全フラグを組み合わせられること'
		When call sx_str_count res "aaa" "a*" "$((1 | 2 | 4))"
		The status should be success
		The variable res should equal 3
	End
End
