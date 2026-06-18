#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_tr()'
	Include ./sx.sh

	It '基本的な変換ができること'
		When call sx_str_tr res "a1b2c3" "abc" "XYZ"
		The variable res should equal "X1Y2Z3"
	End

	It 'from が空の場合は元の文字列をそのまま返すこと'
		When call sx_str_tr res "hello" "" "XYZ"
		The variable res should equal "hello"
	End

	It '空文字列に対して空文字列を返すこと'
		When call sx_str_tr res "" "abc" "XYZ"
		The variable res should equal ""
	End

	It 'from にない文字はそのまま保持されること'
		When call sx_str_tr res "hello" "xyz" "123"
		The variable res should equal "hello"
	End

	It 'to が from より短い場合、超過文字は削除されること'
		When call sx_str_tr res "abcdef" "cde" "12"
		The variable res should equal "ab12f"
	End

	It 'to が from より長い場合、余剰の to は無視されること'
		When call sx_str_tr res "ab" "ab" "12345"
		The variable res should equal "12"
	End

	It 'from に重複がある場合、最初の出現位置の index が使用されること'
		When call sx_str_tr res "aba" "aab" "XY"
		The variable res should equal "XX"
	End

	It 'メタ文字 (*, ?, [) を含む文字列を処理できること'
		When call sx_str_tr res "a*b?c[d" "*?[" "ABC"
		The variable res should equal "aAbBcCd"
	End

	It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
		readonly MYRO_TR=1
		When call sx_str_tr MYRO_TR "abc" "abc" "XYZ"
		The status should equal 77
	End
End
