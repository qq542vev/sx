#!/bin/sh

eval "$(shellspec - -c) exit 1"


Describe 'sx_arg_find'
	Include ./sx.sh

	Describe '前向き検索 (sx_arg_find)'
		It 'デフォルトで全件一致する'
			sx_arg_find res "b" ::: "a" "b" "c" "b"
			Assert [ "$res" = "2 4" ]
		End

		It '成功時に終了ステータス 0 を返す'
			When call sx_arg_find res "b" ::: "a" "b" "c"
			The status should be success
		End

		It 'バインド形式 Nname: で複数件を指定する'
			sx_arg_find "2res:" "b" ::: "a" "b" "c" "b" "d"
			Assert [ "$res" = "2 4" ]
		End

		It 'バインド形式 Nname: で1件を指定する'
			sx_arg_find "1res:" "b" ::: "a" "b" "c" "b"
			Assert [ "$res" = "2" ]
		End
	End

	Describe '後ろ向き検索 (sx_arg_rfind)'
		It 'デフォルトで全件一致する（末尾から）'
			sx_arg_rfind res "b" ::: "a" "b" "c" "b" "d"
			Assert [ "$res" = "4 2" ]
		End

		It '末尾から1件を取得する'
			sx_arg_rfind "1res:" "b" ::: "a" "b" "c" "b" "d"
			Assert [ "$res" = "4" ]
		End

		It '末尾から複数件を取得する'
			sx_arg_rfind "2res:" "b" ::: "a" "b" "c" "b" "d" "b"
			Assert [ "$res" = "6 4" ]
		End

		It '成功時に終了ステータス 0 を返す'
			When call sx_arg_rfind res "b" ::: "a" "b" "c"
			The status should be success
		End
	End

	Describe 'Glob 検索 (フラグ = SX_ARG_FIND_GLOB)'
		It 'フラグが設定されている場合に glob パターンに一致する'
			sx_arg_find "2res:" "*.txt" "$SX_ARG_FIND_GLOB" ::: "file.txt" "readme.md" "data.txt"
			Assert [ "$res" = "1 3" ]
		End

		It 'デフォルトでは glob パターンに一致しない'
			When call sx_arg_find res "*.txt" ::: "file.txt" "readme.md"
			The status should be failure
			The variable res should equal ""
		End
	End

	Describe 'Callback 検索 (SX_ARG_FIND_CB)'
		It 'コールバックの終了ステータスで一致を判定する'
			is_even() { [ $(($2 % 2)) -eq 0 ]; }
			sx_arg_find res is_even $SX_ARG_FIND_CB ::: 1 2 3 4 5
			Assert [ "$res" = "2 4" ]
		End

		It 'コールバックが 0 を返すと一致とみなす'
			all_true() { return 0; }
			sx_arg_find res all_true $SX_ARG_FIND_CB ::: a b c
			Assert [ "$res" = "1 2 3" ]
		End

		It 'コールバックが非0を返すと一致しない'
			all_false() { return 1; }
			When call sx_arg_find res all_false $SX_ARG_FIND_CB ::: a b c
			The status should be failure
			The variable res should equal ""
		End

		It 'SX_ARG_FIND_TEXT と併用して値自体を収集できる'
			is_gt2() { [ "${2}" -gt 2 ]; }
			sx_arg_find res is_gt2 $((SX_ARG_FIND_CB | SX_ARG_FIND_TEXT)) ::: 1 2 3 4 5
			# TEXT モードでは値がクォートされるため eval で復元して比較
			eval "set -- ${res}"
			Assert [ "$*" = "3 4 5" ]
		End

		It 'バインド形式と併用できる'
			is_even() { [ $(($2 % 2)) -eq 0 ]; }
			sx_arg_find "2res:" is_even $SX_ARG_FIND_CB ::: 1 2 3 4 5 6
			Assert [ "$res" = "2 4" ]
		End

		It '分配代入と併用できる'
			is_even() { [ $(($2 % 2)) -eq 0 ]; }
			sx_arg_find "idx1:idx2" is_even $SX_ARG_FIND_CB ::: 1 2 3 4 5 6
			Assert [ "$idx1" = "2" ]
			Assert [ "$idx2" = "4 6" ]
		End

		It 'コールバック内で外部変数を参照できる'
			min_val=3
			is_ge_min() { [ "${2}" -ge "${min_val}" ]; }
			sx_arg_find res is_ge_min $SX_ARG_FIND_CB ::: 1 2 3 4 5
			Assert [ "$res" = "3 4 5" ]
		End

		It 'GLOB + CALLBACK 同時指定は Usage Error'
			When call sx_arg_find res cb $((SX_ARG_FIND_GLOB | SX_ARG_FIND_CB)) ::: a b
			The status should equal "$SX_EX_USAGE"
		End
	End

	Describe '一致項目なし'
		It '終了ステータス 1 を返し、結果が空になる'
			When call sx_arg_find res "x" ::: "a" "b" "c"
			The status should be failure
			The variable res should equal ""
		End

		It '空のリストに対して空文字列を返す'
			When call sx_arg_find res "b" :::
			The status should be failure
			The variable res should equal ""
		End
	End

	Describe '分配代入 (Bind)'
		It '複数の一致項目を個別の変数に分配する'
			sx_arg_find "idx1:idx2" "b" ::: "a" "b" "c" "b" "d"
			Assert [ "$idx1" = "2" ]
			Assert [ "$idx2" = "4" ]
		End

		It 'コロンを使用して特定のインデックスをスキップする'
			sx_arg_find ":idx2" "b" ::: "a" "b" "c" "b" "d"
			Assert [ "${idx1+set}" != "set" ]
			Assert [ "$idx2" = "4" ]
		End

		It 'バインド形式の最後の変数に残りの一致項目が格納される'
			sx_arg_find "idx1:idx_rest" "b" ::: "a" "b" "c" "b" "d" "b"
			Assert [ "$idx1" = "2" ]
			Assert [ "$idx_rest" = "4 6" ]
		End

		It '一致項目が足りない場合に残りの変数が空になる'
			sx_arg_find "idx1:idx2:idx3" "b" ::: "a" "b" "c" "b"
			Assert [ "$idx1" = "2" ]
			Assert [ "$idx2" = "4" ]
			Assert [ "$idx3" = "" ]
		End

		It '裸の変数名で全件がスペース区切りで格納される'
			sx_arg_find res "b" ::: "a" "b" "c" "b"
			Assert [ "$res" = "2 4" ]
		End
	End

	Describe '::: セパレータ'
		It '::: を使用してオプションを正しく処理する'
			sx_arg_find "2res:" "target" ::: "other" "target" "target"
			Assert [ "$res" = "2 3" ]
		End

		It '::: 以降にデータがない場合に正しく処理する'
			When call sx_arg_find res ::: "target" "other"
			The status should be failure
			The variable res should equal ""
		End
	End

	Describe 'エラーケース'
		It '無効な変数名に対して使用法エラーを返す'
			When call sx_arg_find "1invalid" "target" ::: "target"
			The status should equal "$SX_EX_USAGE"
		End

		It '読み取り専用変数に対して権限エラーを返す'
			readonly RO_VAR=1
			When call sx_arg_find RO_VAR "target" ::: "target"
			The status should equal "$SX_EX_NOPERM"
		End
	End
End
