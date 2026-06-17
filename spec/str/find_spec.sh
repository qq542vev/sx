#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_find'
	Include ./sx.sh

	It '単一一致で index:len を返すこと'
		When call sx_str_find res "hello world" "world"
		The status should be success
		The variable res should equal "6:5"
	End

	It '複数一致をスペース区切りで返すこと'
		When call sx_str_find res "ab_cd_ef" "_"
		The status should be success
		The variable res should equal "2:1 5:1"
	End

	It '重複なしかつ隣接一致を正しく検出すること'
		When call sx_str_find res "a__bc" "__"
		The status should be success
		The variable res should equal "1:2"
	End

	It '空 needle は全境界位置（末尾含む）に長さ0で出力すること'
		When call sx_str_find res "abc" ""
		The status should be success
		The variable res should equal "0:0 1:0 2:0 3:0"
	End

	It '空文字列に空 needle で位置0を返すこと'
		When call sx_str_find res "" ""
		The status should be success
		The variable res should equal "0:0"
	End

	It '空文字列に非空 needle で不一致を返すこと'
		When call sx_str_find res "" "a"
		The status should be failure
		The variable res should equal ""
	End

	It '不一致で空文字列・終了ステータス1を返すこと'
		When call sx_str_find res "abc" "x"
		The status should be failure
		The variable res should equal ""
	End

	It 'バインド形式 Nname: で最大件数を指定できること'
		sx_str_find "2res:" "a_b_c_d" "_"
		Assert [ "$res" = "1:1 3:1" ]
	End

	It 'バインド形式 name:name で分配できること'
		sx_str_find "fst:snd" "a_b_c" "_"
		Assert [ "$fst" = "1:1" ]
		Assert [ "$snd" = "3:1" ]
	End

	It 'バインド形式で超過分は無視されること'
		sx_str_find "1pos:" "a_b" "_"
		Assert [ "$pos" = "1:1" ]
	End

	It '無効な変数名でエラーになること'
		When call sx_str_find "1invalid" "abc" "a"
		The status should eq "$SX_EX_USAGE"
	End

	It '読み取り専用変数でエラーになること'
		readonly ro_var=0
		When call sx_str_find ro_var "abc" "a"
		The status should eq "$SX_EX_NOPERM"
	End
End
