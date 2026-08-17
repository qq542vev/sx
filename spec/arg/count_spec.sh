#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_count'
	Include ./sx.sh

	It '単一一致で1を返すこと'
		When call sx_arg_count res "b" ::: "a" "b" "c"
		The status should be success
		The variable res should equal 1
	End

	It '複数一致を正しくカウントすること'
		When call sx_arg_count res "x" ::: "x" "a" "x" "b" "x"
		The status should be success
		The variable res should equal 3
	End

	It '不一致で0を返すこと'
		When call sx_arg_count res "x" ::: "a" "b" "c"
		The status should be success
		The variable res should equal 0
	End

	It '空リストで0を返すこと'
		When call sx_arg_count res "a" :::
		The status should be success
		The variable res should equal 0
	End

	It '空の検索対象で空要素の数を返すこと'
		When call sx_arg_count res "" ::: "a" "" "c"
		The status should be success
		The variable res should equal 1
	End

	It '::: 省略で空要素の数を返すこと'
		When call sx_arg_count res "a" "" "c"
		The status should be success
		The variable res should equal 1
	End

	It '特殊文字を含む値を正しくカウントすること'
		When call sx_arg_count res "'" ::: "a" "'" "b" "'"
		The status should be success
		The variable res should equal 2
	End

	It 'globモードでワイルドカード * が機能すること'
		When call sx_arg_count res "a*" "$SX_ARG_COUNT_GLOB" ::: "a1" "b" "a2" "c"
		The status should be success
		The variable res should equal 2
	End

	It 'globモードで一致なしは0を返すこと'
		When call sx_arg_count res "x*" "$SX_ARG_COUNT_GLOB" ::: "a" "b" "c"
		The status should be success
		The variable res should equal 0
	End

	Describe 'Callback モード (SX_ARG_COUNT_CB)'
		It 'コールバックの終了ステータスで一致をカウントすること'
			is_even() { [ $(($1 % 2)) -eq 0 ]; }
			When call sx_arg_count res is_even $SX_ARG_COUNT_CB ::: 1 2 3 4 5
			The status should be success
			The variable res should equal 2
		End

		It '全要素がコールバックに一致した場合'
			all_true() { return 0; }
			When call sx_arg_count res all_true $SX_ARG_COUNT_CB ::: a b c
			The status should be success
			The variable res should equal 3
		End

		It 'コールバックの一致なしで0を返すこと'
			all_false() { return 1; }
			When call sx_arg_count res all_false $SX_ARG_COUNT_CB ::: a b c
			The status should be success
			The variable res should equal 0
		End

		It 'SX_ARG_FIND_TEXT と併用できること'
			is_gt2() { [ "${1}" -gt 2 ]; }
			When call sx_arg_count res is_gt2 $((SX_ARG_COUNT_CB | SX_ARG_FIND_TEXT)) ::: 1 2 3 4 5
			The status should be success
			The variable res should equal 3
		End

		It 'コールバック内で外部変数を参照できること'
			min_val=3
			is_ge_min() { [ "${1}" -ge "${min_val}" ]; }
			When call sx_arg_count res is_ge_min $SX_ARG_COUNT_CB ::: 1 2 3 4 5
			The status should be success
			The variable res should equal 3
		End
	End

	It 'GLOB + CALLBACK 同時指定は Usage Error'
		When call sx_arg_count res cb $((SX_ARG_COUNT_GLOB | SX_ARG_COUNT_CB)) ::: a b
		The status should equal "$SX_EX_USAGE"
	End

	It '読み取り専用変数でエラーになること'
		readonly ro_var=0
		When call sx_arg_count ro_var "a" ::: "a" "b" "a"
		The status should eq "$SX_EX_NOPERM"
	End

	It '高速モード (SX_CFG_SKIP_CHK=1) で正しく動作すること'
		SX_CFG_SKIP_CHK=1
		When call sx_arg_count res "x" ::: "x" "y" "x"
		The status should be success
		The variable res should equal 2
	End

	Describe '内部関数 (__sx_arg_count)'
		It '__sx_arg_count が正しく動作すること'
			When call __sx_arg_count res "a" ::: "a" "b" "a" "c"
			The status should be success
			The variable res should equal 2
		End
	End
End
