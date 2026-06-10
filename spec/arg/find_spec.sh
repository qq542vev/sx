# shellcheck shell=sh

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
