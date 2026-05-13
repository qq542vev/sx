# shellcheck shell=sh

Describe 'sx_arg_find'
	Include ./sx.sh

	Describe '順方向検索 (上限 > 0)'
		It 'デフォルトで最初の一致項目を見つける'
			sx_arg_find res "b" ::: "a" "b" "c" "b"
			Assert [ "$res" = "2" ]
		End

		It '成功時に終了ステータス 0 を返す'
			When call sx_arg_find res "b" ::: "a" "b" "c"
			The status should be success
		End

		It '上限が 1 より大きい場合に複数の一致項目を見つける'
			sx_arg_find res "b" 2 ::: "a" "b" "c" "b" "d"
			Assert [ "$res" = "2 4" ]
		End

		It '指定された上限まで見つける'
			sx_arg_find res "b" 1 ::: "a" "b" "c" "b"
			Assert [ "$res" = "2" ]
		End
	End

	Describe '逆方向検索 (上限 < 0)'
		It '上限が -1 の場合に最後の一致項目を見つける'
			sx_arg_find res "b" -1 ::: "a" "b" "c" "b" "d"
			Assert [ "$res" = "4" ]
		End

		It '末尾から逆順で一致項目を返す'
			sx_arg_find res "b" -2 ::: "a" "b" "c" "b" "d" "b"
			Assert [ "$res" = "6 4" ]
		End
	End

	Describe 'Glob 検索 (フラグ = SX_ARG_FIND_GLOB)'
		It 'フラグが設定されている場合に glob パターンに一致する'
			sx_arg_find res "*.txt" 2 "$SX_ARG_FIND_GLOB" ::: "file.txt" "readme.md" "data.txt"
			Assert [ "$res" = "1 3" ]
		End

		It 'デフォルトでは glob パターンに一致しない'
			When call sx_arg_find res "*.txt" ::: "file.txt" "readme.md"
			The status should be failure
			The variable res should equal ""
		End
	End

	Describe '上限 = 0'
		It '終了ステータス 1 を返し、結果が空になる'
			When call sx_arg_find res "b" 0 ::: "a" "b" "c"
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

	Describe '::: セパレータ'
		It '::: を使用してオプションを正しく処理する'
			sx_arg_find res "target" 2 0 ::: "other" "target" "target"
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

	Describe '厳密な引数チェック'
		It '無効な上限値（数値以外）に対して使用法エラーを返す'
			When call sx_arg_find res "target" "invalid" ::: "target"
			The status should equal "$SX_EX_USAGE"
		End

		It '無効なフラグ（数値以外）に対して使用法エラーを返す'
			When call sx_arg_find res "target" 1 "invalid" ::: "target"
			The status should equal "$SX_EX_USAGE"
		End

		It '負のフラグを許容する'
			When call sx_arg_find res "target" 1 -1 ::: "target"
			The status should be success
		End
	End
End
