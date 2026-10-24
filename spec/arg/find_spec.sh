#!/bin/sh
# shellcheck shell=sh disable=SC2154,SC2329
# 結果変数は参照渡しで設定され、コールバックはテスト対象から間接的に呼ばれる。

eval "$(shellspec - -c) exit 1"


Describe 'sx_arg_find'
	# Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
	load_subject() {
		case "$1" in
			sx_arg_find)
				sxtest_load ./build/modules/sx_arg_find.sh
				;;
			sx_arg_rfind)
				sxtest_load ./build/modules/sx_arg_rfind.sh
				;;
			*) return 64;;
		esac
	}


	Describe '前向き検索 (sx_arg_find)'
		It 'デフォルトで全件一致する'
			load_subject sx_arg_find
			sx_arg_find res "b" ::: "a" "b" "c" "b"
			Assert [ "$res" = "2 4" ]
		End

		It '成功時に終了ステータス 0 を返す'
			load_subject sx_arg_find
			When call sx_arg_find res "b" ::: "a" "b" "c"
			The status should be success
		End

		It 'バインド形式 Nname: で複数件を指定する'
			load_subject sx_arg_find
			sx_arg_find "2res:" "b" ::: "a" "b" "c" "b" "d"
			Assert [ "$res" = "2 4" ]
		End

		It 'バインド形式 Nname: で1件を指定する'
			load_subject sx_arg_find
			sx_arg_find "1res:" "b" ::: "a" "b" "c" "b"
			Assert [ "$res" = "2" ]
		End
	End

	Describe '後ろ向き検索 (sx_arg_rfind)'
		It 'デフォルトで全件一致する（末尾から）'
			load_subject sx_arg_rfind
			sx_arg_rfind res "b" ::: "a" "b" "c" "b" "d"
			Assert [ "$res" = "4 2" ]
		End

		It '末尾から1件を取得する'
			load_subject sx_arg_rfind
			sx_arg_rfind "1res:" "b" ::: "a" "b" "c" "b" "d"
			Assert [ "$res" = "4" ]
		End

		It '末尾から複数件を取得する'
			load_subject sx_arg_rfind
			sx_arg_rfind "2res:" "b" ::: "a" "b" "c" "b" "d" "b"
			Assert [ "$res" = "6 4" ]
		End

		It '成功時に終了ステータス 0 を返す'
			load_subject sx_arg_rfind
			When call sx_arg_rfind res "b" ::: "a" "b" "c"
			The status should be success
		End
	End

	Describe 'Glob 検索 (フラグ = SX_ARG_FIND_GLOB)'
		It 'フラグが設定されている場合に glob パターンに一致する'
			load_subject sx_arg_find
			sx_arg_find "2res:" "*.txt" "1" ::: "file.txt" "readme.md" "data.txt"
			Assert [ "$res" = "1 3" ]
		End

		It 'デフォルトでは glob パターンに一致しない'
			load_subject sx_arg_find
			When call sx_arg_find res "*.txt" ::: "file.txt" "readme.md"
			The status should be failure
			The variable res should equal ""
		End
	End

	Describe 'Callback 検索 (SX_ARG_FIND_CB)'
		It 'コールバックの終了ステータスで一致を判定する'
			load_subject sx_arg_find
			is_even() { [ $(($2 % 2)) -eq 0 ]; }
			sx_arg_find res is_even "2" ::: 1 2 3 4 5
			Assert [ "$res" = "2 4" ]
		End

		It 'コールバックが 0 を返すと一致とみなす'
			load_subject sx_arg_find
			all_true() { return 0; }
			sx_arg_find res all_true "2" ::: a b c
			Assert [ "$res" = "1 2 3" ]
		End

		It 'コールバックが非0を返すと一致しない'
			load_subject sx_arg_find
			all_false() { return 1; }
			When call sx_arg_find res all_false "2" ::: a b c
			The status should be failure
			The variable res should equal ""
		End

		It 'SX_ARG_FIND_TEXT と併用して値自体を収集できる'
			load_subject sx_arg_find
			is_gt2() { [ "${2}" -gt 2 ]; }
			sx_arg_find res is_gt2 $((2 | 4)) ::: 1 2 3 4 5
			# TEXT モードでは値がクォートされるため eval で復元して比較
			eval "set -- ${res}"
			Assert [ "$*" = "3 4 5" ]
		End

		It 'バインド形式と併用できる'
			load_subject sx_arg_find
			is_even() { [ $(($2 % 2)) -eq 0 ]; }
			sx_arg_find "2res:" is_even "2" ::: 1 2 3 4 5 6
			Assert [ "$res" = "2 4" ]
		End

		It '分配代入と併用できる'
			load_subject sx_arg_find
			is_even() { [ $(($2 % 2)) -eq 0 ]; }
			sx_arg_find "idx1:idx2" is_even "2" ::: 1 2 3 4 5 6
			Assert [ "$idx1" = "2" ]
			Assert [ "$idx2" = "4 6" ]
		End

		It 'コールバック内で外部変数を参照できる'
			load_subject sx_arg_find
			min_val=3
			is_ge_min() { [ "${2}" -ge "${min_val}" ]; }
			sx_arg_find res is_ge_min "2" ::: 1 2 3 4 5
			Assert [ "$res" = "3 4 5" ]
		End

		It 'GLOB + CALLBACK 同時指定は Usage Error'
			load_subject sx_arg_find
			When call sx_arg_find res cb $((1 | 2)) ::: a b
			The status should equal "64"
		End
	End

	Describe '一致項目なし'
		It '終了ステータス 1 を返し、結果が空になる'
			load_subject sx_arg_find
			When call sx_arg_find res "x" ::: "a" "b" "c"
			The status should be failure
			The variable res should equal ""
		End

		It '空のリストに対して空文字列を返す'
			load_subject sx_arg_find
			When call sx_arg_find res "b" :::
			The status should be failure
			The variable res should equal ""
		End
	End

	Describe '分配代入 (Bind)'
		It '複数の一致項目を個別の変数に分配する'
			load_subject sx_arg_find
			sx_arg_find "idx1:idx2" "b" ::: "a" "b" "c" "b" "d"
			Assert [ "$idx1" = "2" ]
			Assert [ "$idx2" = "4" ]
		End

		It 'コロンを使用して特定のインデックスをスキップする'
			load_subject sx_arg_find
			sx_arg_find ":idx2" "b" ::: "a" "b" "c" "b" "d"
			Assert [ "${idx1+set}" != "set" ]
			Assert [ "$idx2" = "4" ]
		End

		It 'バインド形式の最後の変数に残りの一致項目が格納される'
			load_subject sx_arg_find
			sx_arg_find "idx1:idx_rest" "b" ::: "a" "b" "c" "b" "d" "b"
			Assert [ "$idx1" = "2" ]
			Assert [ "$idx_rest" = "4 6" ]
		End

		It '一致項目が足りない場合に残りの変数が空になる'
			load_subject sx_arg_find
			sx_arg_find "idx1:idx2:idx3" "b" ::: "a" "b" "c" "b"
			Assert [ "$idx1" = "2" ]
			Assert [ "$idx2" = "4" ]
			Assert [ "$idx3" = "" ]
		End

		It '裸の変数名で全件がスペース区切りで格納される'
			load_subject sx_arg_find
			sx_arg_find res "b" ::: "a" "b" "c" "b"
			Assert [ "$res" = "2 4" ]
		End
	End

	Describe '::: セパレータ'
		It '::: を使用してオプションを正しく処理する'
			load_subject sx_arg_find
			sx_arg_find "2res:" "target" ::: "other" "target" "target"
			Assert [ "$res" = "2 3" ]
		End

		It '検索対象を省略すると空文字列を探す'
			load_subject sx_arg_find
			When call sx_arg_find res ::: "target" "other"
			The status should be failure
			The variable res should equal ""
		End

		It '設定を省略して空要素のインデックスを返す'
			load_subject sx_arg_find
			When call sx_arg_find res ::: a '' c
			The status should be success
			The variable res should equal 2
		End
	End

	Describe '簡易形式（bind・検索対象・データ）'
		It '第2引数を検索対象とし数値のデータもフラグとして消費しない'
			load_subject sx_arg_find
			When call sx_arg_find res b b 1 b
			The status should be success
			The variable res should equal '1 3'
		End
	End

	Describe 'エラーケース'
		It '空白を含む bind を分割せず使用法エラーにする'
			load_subject sx_arg_find
			When call sx_arg_find 'a b' target ::: target
			The status should equal "64"
			The variable a should be undefined
			The variable b should be undefined
		End

		It '無効な変数名に対して使用法エラーを返す'
			load_subject sx_arg_find
			When call sx_arg_find "1invalid" "target" ::: "target"
			The status should equal "64"
		End

		It '読み取り専用変数に対して権限エラーを返す'
			load_subject sx_arg_find
			readonly RO_VAR=1
			When call sx_arg_find RO_VAR "target" ::: "target"
			The status should equal "77"
		End
	End
End
