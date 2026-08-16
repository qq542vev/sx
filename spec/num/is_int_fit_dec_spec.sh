Describe 'sx_num_is_int_fit_dec'
	Include ./sx.sh

	Describe '有効な32bit符号付き整数'
		It '0 を受理すること'
			When call sx_num_is_int_fit_dec 32 0
			The status should be success
		End

		It '正の最小値 1 を受理すること'
			When call sx_num_is_int_fit_dec 32 1
			The status should be success
		End

		It '正の最大値 2147483647 を受理すること'
			When call sx_num_is_int_fit_dec 32 2147483647
			The status should be success
		End

		It '負の最小値 -1 を受理すること'
			When call sx_num_is_int_fit_dec 32 -1
			The status should be success
		End

		It '負の最大値 -2147483648 を受理すること'
			When call sx_num_is_int_fit_dec 32 -2147483648
			The status should be success
		End

		It '+ 付きの正の数 +100 を受理すること'
			When call sx_num_is_int_fit_dec 32 +100
			The status should be success
		End

		It '9桁の正の数 999999999 を受理すること'
			When call sx_num_is_int_fit_dec 32 999999999
			The status should be success
		End

		It '9桁の負の数 -999999999 を受理すること'
			When call sx_num_is_int_fit_dec 32 -999999999
			The status should be success
		End

		It '+2147483647 を受理すること'
			When call sx_num_is_int_fit_dec 32 +2147483647
			The status should be success
		End

		It '複数の有効な引数を受理すること'
			When call sx_num_is_int_fit_dec 32 0 1 -1 2147483647 -2147483648 +100
			The status should be success
		End
	End

	Describe '無効な値（範囲外）'
		It '2147483648 を拒否すること（INT_MAX + 1）'
			When call sx_num_is_int_fit_dec 32 2147483648
			The status should be failure
		End

		It '-2147483649 を拒否すること（INT_MIN - 1）'
			When call sx_num_is_int_fit_dec 32 -2147483649
			The status should be failure
		End

		It '10桁の正の数 9999999999 を拒否すること'
			When call sx_num_is_int_fit_dec 32 9999999999
			The status should be failure
		End

		It '11桁の負の数 -10000000000 を拒否すること'
			When call sx_num_is_int_fit_dec 32 -10000000000
			The status should be failure
		End

		It '+2147483648 を拒否すること'
			When call sx_num_is_int_fit_dec 32 +2147483648
			The status should be failure
		End
	End

	Describe '無効な値（不正形式）'
		It '空文字列を拒否すること'
			When call sx_num_is_int_fit_dec 32 ''
			The status should be failure
		End

		It '英字を含む文字列を拒否すること'
			When call sx_num_is_int_fit_dec 32 abc
			The status should be failure
		End

		It '符号のみを拒否すること'
			When call sx_num_is_int_fit_dec 32 +
			The status should be failure
		End

		It '負号のみを拒否すること'
			When call sx_num_is_int_fit_dec 32 -
			The status should be failure
		End

		It '先行ゼロを含む数値を拒否すること'
			When call sx_num_is_int_fit_dec 32 01
			The status should be failure
		End

		It '空白を含む文字列を拒否すること'
			When call sx_num_is_int_fit_dec 32 ' 1'
			The status should be failure
		End

		It '複数符号を拒否すること'
			When call sx_num_is_int_fit_dec 32 ++1
			The status should be failure
		End
	End
End
