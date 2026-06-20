#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_tr()'
	Include ./sx.sh

	It '基本的な変換ができること'
		When call sx_str_tr res:cnt "a1b2c3" "abc" "XYZ"
		The variable res should equal "X1Y2Z3"
		The variable cnt should equal "'3'"
	End

	It 'from が空の場合は元の文字列をそのまま返すこと'
		When call sx_str_tr res:cnt "hello" "" "XYZ"
		The variable res should equal "hello"
		The variable cnt should equal "'0'"
	End

	It '空文字列に対して空文字列を返すこと'
		When call sx_str_tr res:cnt "" "abc" "XYZ"
		The variable res should equal ""
		The variable cnt should equal "'0'"
	End

	It 'from にない文字はそのまま保持されること'
		When call sx_str_tr res:cnt "hello" "xyz" "123"
		The variable res should equal "hello"
		The variable cnt should equal "'0'"
	End

	It 'to が from より短い場合、超過文字は削除されること'
		When call sx_str_tr res:cnt "abcdef" "cde" "12"
		The variable res should equal "ab12f"
		The variable cnt should equal "'3'"
	End

	It 'to が from より長い場合、余剰の to は無視されること'
		When call sx_str_tr res:cnt "ab" "ab" "12345"
		The variable res should equal "12"
		The variable cnt should equal "'2'"
	End

	It 'from に重複がある場合、最初の出現位置の index が使用されること'
		When call sx_str_tr res:cnt "aba" "aab" "XY"
		The variable res should equal "XX"
		The variable cnt should equal "'3'"
	End

	It 'メタ文字 (*, ?, [) を含む文字列を処理できること'
		When call sx_str_tr res:cnt "a*b?c[d" "*?[" "ABC"
		The variable res should equal "aAbBcCd"
		The variable cnt should equal "'3'"
	End

	It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
		readonly MYRO_TR=1
		When call sx_str_tr MYRO_TR "abc" "abc" "XYZ"
		The status should equal 77
	End

	It 'limit=0 の場合は何も置換しないこと'
		When call sx_str_tr res:cnt "abc" "abc" "XYZ" 0
		The variable res should equal "abc"
		The variable cnt should equal "'0'"
	End

	It 'limit=1 で前方1回だけ置換すること'
		When call sx_str_tr res:cnt "a1b2c3" "abc" "XYZ" 1
		The variable res should equal "X1b2c3"
		The variable cnt should equal "'1'"
	End

	It 'limit=2 で前方2回だけ置換すること'
		When call sx_str_tr res:cnt "a1b2c3" "abc" "XYZ" 2
		The variable res should equal "X1Y2c3"
		The variable cnt should equal "'2'"
	End

	It 'limit がマッチ数を超える場合は全置換すること'
		When call sx_str_tr res:cnt "abc" "abc" "XYZ" 5
		The variable res should equal "XYZ"
		The variable cnt should equal "'3'"
	End

	It 'limit=-1 で後方1回だけ置換すること'
		When call sx_str_tr res:cnt "a1b2c3" "abc" "XYZ" -1
		The variable res should equal "a1b2Z3"
		The variable cnt should equal "'1'"
	End

	It 'limit=-2 で後方2回だけ置換すること'
		When call sx_str_tr res:cnt "a1b2c3" "abc" "XYZ" -2
		The variable res should equal "a1Y2Z3"
		The variable cnt should equal "'2'"
	End

	It '後方置換で limit がマッチ数を超える場合は全置換すること'
		When call sx_str_tr res:cnt "abc" "abc" "XYZ" -5
		The variable res should equal "XYZ"
		The variable cnt should equal "'3'"
	End

	It '後方置換で to が短い場合、超過文字が削除されること'
		When call sx_str_tr res:cnt "abcdef" "cde" "12" -2
		The variable res should equal "abc2f"
		The variable cnt should equal "'2'"
	End

	It 'limit 省略時は全置換すること'
		When call sx_str_tr res:cnt "a1b2c3" "abc" "XYZ"
		The variable res should equal "X1Y2Z3"
		The variable cnt should equal "'3'"
	End

	It 'バインド形式 res: (末尾コロン) で結果のみ取得できること'
		When call sx_str_tr res: "a1b2c3" "abc" "XYZ"
		The variable res should equal "X1Y2Z3"
	End

	It 'バインド形式 :cnt (先頭コロン) でカウントのみ取得できること'
		When call sx_str_tr :cnt "a1b2c3" "abc" "XYZ"
		The variable cnt should equal "'3'"
	End

	It 'バインド形式 res (単純変数名) で結果とカウントが累積されること'
		When call sx_str_tr res "a1b2c3" "abc" "XYZ"
		The variable res should equal "'X1Y2Z3' '3'"
	End

	It 'from-set に ] が含まれても正しく変換できること'
		When call sx_str_tr res:cnt "a]b" "ab]" "XY_"
		The variable res should equal "X_Y"
		The variable cnt should equal "'3'"
	End

	It 'from-set が ] のみの場合も正しく変換できること'
		When call sx_str_tr res:cnt "a]b" "]" "Z"
		The variable res should equal "aZb"
		The variable cnt should equal "'1'"
	End

	It 'from-set の先頭に ] がある場合も正しく処理できること'
		When call sx_str_tr res:cnt "a]b" "]ab" "XYZ"
		The variable res should equal "YXZ"
		The variable cnt should equal "'3'"
	End

	It 'from-set に ] があり to が短い場合、超過文字として削除されること'
		When call sx_str_tr res:cnt "a]b" "ab]" "XY"
		The variable res should equal "XY"
		The variable cnt should equal "'3'"
	End
End
