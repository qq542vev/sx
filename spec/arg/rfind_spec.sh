#!/bin/sh
# shellcheck shell=sh disable=SC2154,SC2329
# 結果変数は参照渡しで設定され、コールバックはテスト対象から間接的に呼ばれる。

eval "$(shellspec - -c) exit 1"


Describe 'sx_arg_rfind'
	Include ./spec/support/run.sh
	# 検証に使うフラグ定数は、対象モジュールの依存とは別に準備する。
	sxtest_run SX_ARG_RFIND_CB SX_ARG_RFIND_GLOB SX_ARG_RFIND_TEXT SX_ARG_RFIND_NOT SX_ARG_RFIND_POS SX_ARG_RFIND_ICASE SX_ARG_RFIND_EQC -- ''
	sxtest_load ./build/modules/sx_arg_rfind.sh

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

		It '単一要素のリストから正しいインデックスを返す'
			sx_arg_rfind res "a" ::: "a"
			Assert [ "$res" = "1" ]
		End
	End

	Describe 'Glob 検索 (フラグ = SX_ARG_RFIND_GLOB)'
		It 'フラグが設定されている場合に glob パターンに一致する（後ろ向き）'
			sx_arg_rfind "2res:" "*.txt" "$SX_ARG_RFIND_GLOB" ::: "file.txt" "readme.md" "data.txt" "notes.txt"
			Assert [ "$res" = "4 3" ]
		End

		It 'デフォルトでは glob パターンに一致しない'
			When call sx_arg_rfind res "*.txt" ::: "file.txt" "readme.md"
			The status should be failure
			The variable res should equal ""
		End
	End

	Describe 'Callback 検索 (SX_ARG_RFIND_CB)'
		It 'コールバックの終了ステータスで一致を判定する（後ろ向き）'
			is_even() { [ $(($2 % 2)) -eq 0 ]; }
			sx_arg_rfind res is_even "$SX_ARG_RFIND_CB" ::: 1 2 3 4 5
			Assert [ "$res" = "4 2" ]
		End

		It 'コールバックが 0 を返すと一致とみなす'
			all_true() { return 0; }
			sx_arg_rfind res all_true "$SX_ARG_RFIND_CB" ::: a b c
			Assert [ "$res" = "3 2 1" ]
		End

		It 'コールバックが非0を返すと一致しない'
			all_false() { return 1; }
			When call sx_arg_rfind res all_false "$SX_ARG_RFIND_CB" ::: a b c
			The status should be failure
			The variable res should equal ""
		End

		It 'SX_ARG_RFIND_TEXT と併用して値自体を収集できる'
			is_gt2() { [ "${2}" -gt 2 ]; }
			sx_arg_rfind res is_gt2 $((SX_ARG_RFIND_CB | SX_ARG_RFIND_TEXT)) ::: 1 2 3 4 5
			eval "set -- ${res}"
			Assert [ "$*" = "5 4 3" ]
		End

		It 'バインド形式と併用できる'
			is_even() { [ $(($2 % 2)) -eq 0 ]; }
			sx_arg_rfind "2res:" is_even "$SX_ARG_RFIND_CB" ::: 1 2 3 4 5 6
			Assert [ "$res" = "6 4" ]
		End

		It '分配代入と併用できる'
			is_even() { [ $(($2 % 2)) -eq 0 ]; }
			sx_arg_rfind "idx1:idx2" is_even "$SX_ARG_RFIND_CB" ::: 1 2 3 4 5 6
			Assert [ "$idx1" = "6" ]
			Assert [ "$idx2" = "4 2" ]
		End

		It 'コールバック内で外部変数を参照できる'
			min_val=3
			is_ge_min() { [ "${2}" -ge "${min_val}" ]; }
			sx_arg_rfind res is_ge_min "$SX_ARG_RFIND_CB" ::: 1 2 3 4 5
			Assert [ "$res" = "5 4 3" ]
		End

		It 'コールバック内で sx_arg_rfind を再帰呼び出ししても状態が壊れないこと'
			recursive_cb() {
				if [ "$1" = "4" ]; then
					sx_arg_rfind inner_res is_even_rec "$SX_ARG_RFIND_CB" ::: 1 2 3
				fi
				[ $(($1 % 2)) -eq 0 ]
			}
			is_even_rec() {
				[ $(($1 % 2)) -eq 0 ]
			}
			sx_arg_rfind res recursive_cb "$SX_ARG_RFIND_CB" ::: 1 2 3 4 5
			Assert [ "$res" = "4 2" ]
			Assert [ "$inner_res" = "2" ]
		End

		It 'GLOB + CALLBACK 同時指定は Usage Error'
			When call sx_arg_rfind res cb $((SX_ARG_RFIND_GLOB | SX_ARG_RFIND_CB)) ::: a b
			The status should equal 64
		End
	End

	Describe '否定一致 (SX_ARG_RFIND_NOT)'
		It '一致しない要素のインデックスを末尾から返す'
			sx_arg_rfind res "b" "$SX_ARG_RFIND_NOT" ::: "a" "b" "c" "b" "d"
			Assert [ "$res" = "5 3 1" ]
		End

		It 'TEXT と併用して一致しない値を返す'
			sx_arg_rfind res "b" $((SX_ARG_RFIND_NOT | SX_ARG_RFIND_TEXT)) ::: "a" "b" "c"
			eval "set -- ${res}"
			Assert [ "$*" = "c a" ]
		End

		It 'GLOB と併用する'
			sx_arg_rfind res "*.txt" $((SX_ARG_RFIND_NOT | SX_ARG_RFIND_GLOB)) ::: "a.txt" "b.md" "c.txt"
			Assert [ "$res" = "2" ]
		End

		It 'CB と併用する'
			is_even() { [ $(($2 % 2)) -eq 0 ]; }
			sx_arg_rfind res is_even $((SX_ARG_RFIND_NOT | SX_ARG_RFIND_CB)) ::: 1 2 3 4 5
			Assert [ "$res" = "5 3 1" ]
		End

		It '全件一致なら 1 を返し空になる'
			When call sx_arg_rfind res "a" "$SX_ARG_RFIND_NOT" ::: "a" "a"
			The status should be failure
			The variable res should equal ""
		End

		It '空データなら 1 を返す'
			When call sx_arg_rfind res "a" "$SX_ARG_RFIND_NOT" :::
			The status should be failure
			The variable res should equal ""
		End
	End

	Describe '一致項目なし'
		It '終了ステータス 1 を返し、結果が空になる'
			When call sx_arg_rfind res "x" ::: "a" "b" "c"
			The status should be failure
			The variable res should equal ""
		End

		It '空のリストに対して空文字列を返す'
			When call sx_arg_rfind res "b" :::
			The status should be failure
			The variable res should equal ""
		End
	End

	Describe '分配代入 (Bind)'
		It '複数の一致項目を個別の変数に分配する'
			sx_arg_rfind "idx1:idx2" "b" ::: "a" "b" "c" "b" "d"
			Assert [ "$idx1" = "4" ]
			Assert [ "$idx2" = "2" ]
		End

		It 'コロンを使用して最初の一致をスキップする'
			sx_arg_rfind ":idx2" "b" ::: "a" "b" "c" "b" "d"
			Assert [ "${idx1+set}" != "set" ]
			Assert [ "$idx2" = "2" ]
		End

		It 'バインド形式の最後の変数に残りの一致項目が格納される'
			sx_arg_rfind "idx1:idx_rest" "b" ::: "a" "b" "c" "b" "d" "b"
			Assert [ "$idx1" = "6" ]
			Assert [ "$idx_rest" = "4 2" ]
		End

		It '一致項目が足りない場合に残りの変数が空になる'
			sx_arg_rfind "idx1:idx2:idx3" "b" ::: "a" "b" "c" "b"
			Assert [ "$idx1" = "4" ]
			Assert [ "$idx2" = "2" ]
			Assert [ "$idx3" = "" ]
		End

		It '裸の変数名で全件がスペース区切りで格納される'
			sx_arg_rfind res "b" ::: "a" "b" "c" "b"
			Assert [ "$res" = "4 2" ]
		End
	End

	Describe '::: セパレータ'
		It '::: を使用してオプションを正しく処理する'
			sx_arg_rfind "2res:" "target" ::: "other" "target" "target"
			Assert [ "$res" = "3 2" ]
		End

		It '検索対象を省略すると空文字列を探す'
			When call sx_arg_rfind res ::: "target" "other"
			The status should be failure
			The variable res should equal ""
		End
	End

	Describe '簡易形式（bind・検索対象・データ）'
		It '第2引数を検索対象とし数値のデータもフラグとして消費しない'
			When call sx_arg_rfind res b b 1 b
			The status should be success
			The variable res should equal '3 1'
		End
	End

	Describe '出力形式フラグ (sx_arg_rfind)'
		It 'POS のみでインデックスのみを末尾から返すこと'
			When call sx_arg_rfind res "b" "$SX_ARG_RFIND_POS" ::: a b c b
			The status should be success
			The variable res should equal '4 2'
		End

		It '出力形式未指定は POS と同じこと'
			When call sx_arg_rfind res "b" 0 ::: a b c b
			The status should be success
			The variable res should equal '4 2'
		End

		It 'POS|TEXT で pos:text を末尾から返すこと'
			sx_arg_rfind res "b" "$(($SX_ARG_RFIND_POS | $SX_ARG_RFIND_TEXT))" ::: a b c b
			Assert [ "$res" = "'4:b' '2:b'" ]
		End

		It '指定順が POS:TEXT の順に影響しないこと'
			sx_arg_rfind res "b" "$(($SX_ARG_RFIND_TEXT | $SX_ARG_RFIND_POS))" ::: a b c b
			Assert [ "$res" = "'4:b' '2:b'" ]
		End

		It '空文字列の値でも区切りを残すこと'
			sx_arg_rfind res "" "$(($SX_ARG_RFIND_POS | $SX_ARG_RFIND_TEXT))" ::: a '' c ''
			Assert [ "$res" = "'4:' '2:'" ]
		End

		It 'GLOB と併用できること'
			sx_arg_rfind res "*.txt" "$(($SX_ARG_RFIND_GLOB | $SX_ARG_RFIND_POS | $SX_ARG_RFIND_TEXT))" ::: file.txt readme.md data.txt
			Assert [ "$res" = "'3:data.txt' '1:file.txt'" ]
		End

		It 'CB と併用できること'
			is_even() { [ $(($2 % 2)) -eq 0 ]; }
			sx_arg_rfind res is_even "$(($SX_ARG_RFIND_CB | $SX_ARG_RFIND_POS | $SX_ARG_RFIND_TEXT))" ::: 1 2 3 4
			Assert [ "$res" = "'4:4' '2:2'" ]
		End

		It 'NOT と併用できること'
			sx_arg_rfind res "b" "$(($SX_ARG_RFIND_NOT | $SX_ARG_RFIND_POS | $SX_ARG_RFIND_TEXT))" ::: a b c b
			Assert [ "$res" = "'3:c' '1:a'" ]
		End
	End

	Describe '大小無視検索 (SX_ARG_RFIND_ICASE)'
		It '英字の大小を区別せずに末尾から一致する'
			sx_arg_rfind res "cafe" "$SX_ARG_RFIND_ICASE" ::: "CAFE" "cafe" "Cafe" "tea"
			Assert [ "$res" = "3 2 1" ]
		End

		It 'glob 特殊文字をリテラルとして扱う'
			sx_arg_rfind res "*" "$SX_ARG_RFIND_ICASE" ::: "*" "abc"
			Assert [ "$res" = "1" ]
		End

		It 'NOT と併用できる'
			sx_arg_rfind res "cafe" "$(($SX_ARG_RFIND_ICASE | $SX_ARG_RFIND_NOT))" ::: "CAFE" "tea" "cafe"
			Assert [ "$res" = "2" ]
		End

		It 'POS と TEXT を併用できる'
			sx_arg_rfind res "cafe" "$(($SX_ARG_RFIND_ICASE | $SX_ARG_RFIND_POS | $SX_ARG_RFIND_TEXT))" ::: "CAFE" "tea" "cafe"
			Assert [ "$res" = "'3:cafe' '1:CAFE'" ]
		End
	End

	Describe '等価クラス検索 (SX_ARG_RFIND_EQC)'
		It 'C ロケールではリテラル一致として動作する'
			LC_ALL=C
			sx_arg_rfind res "cafe" "$SX_ARG_RFIND_EQC" ::: "cafe" "CAFE" "café"
			Assert [ "$res" = "1" ]
		End

		It 'glob 特殊文字をリテラルとして扱う'
			LC_ALL=C
			sx_arg_rfind res "*" "$SX_ARG_RFIND_EQC" ::: "*" "abc"
			Assert [ "$res" = "1" ]
		End

		It 'NOT と併用できる'
			LC_ALL=C
			sx_arg_rfind res "cafe" "$(($SX_ARG_RFIND_EQC | $SX_ARG_RFIND_NOT))" ::: "cafe" "tea"
			Assert [ "$res" = "2" ]
		End
	End

	Describe '照合モードの排他'
		It 'ICASE と EQC の同時指定は Usage Error'
			When call sx_arg_rfind res a "$(($SX_ARG_RFIND_ICASE | $SX_ARG_RFIND_EQC))" ::: a b
			The status should equal 64
		End

		It 'ICASE と GLOB の同時指定は Usage Error'
			When call sx_arg_rfind res a "$(($SX_ARG_RFIND_ICASE | $SX_ARG_RFIND_GLOB))" ::: a b
			The status should equal 64
		End

		It 'ICASE と CB の同時指定は Usage Error'
			When call sx_arg_rfind res cb "$(($SX_ARG_RFIND_ICASE | $SX_ARG_RFIND_CB))" ::: a b
			The status should equal 64
		End

		It 'EQC と GLOB の同時指定は Usage Error'
			When call sx_arg_rfind res a "$(($SX_ARG_RFIND_EQC | $SX_ARG_RFIND_GLOB))" ::: a b
			The status should equal 64
		End

		It 'EQC と CB の同時指定は Usage Error'
			When call sx_arg_rfind res cb "$(($SX_ARG_RFIND_EQC | $SX_ARG_RFIND_CB))" ::: a b
			The status should equal 64
		End
	End

	Describe 'エラーケース'
		It '無効な変数名に対して使用法エラーを返す'
			When call sx_arg_rfind "1invalid" "target" ::: "target"
			The status should equal 64
		End

		It '読み取り専用変数に対して権限エラーを返す'
			readonly RO_VAR=1
			When call sx_arg_rfind RO_VAR "target" ::: "target"
			The status should equal 77
		End
	End
End
