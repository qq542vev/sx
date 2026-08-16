Describe 'sx_num_is_int_fit'
	Include ./sx.sh

	Describe '有効な値'
		It '8bit の範囲内の値を成功させる'
			When call sx_num_is_int_fit 8 "127" "-128" "0177" "-0200" "0x7F" "-0x80"
			The status should be success
		End

		It '16bit の範囲内の値を成功させる'
			When call sx_num_is_int_fit 16 "32767" "-32768" "077777" "-0100000" "0x7FFF" "-0x8000"
			The status should be success
		End

		It '32bit の範囲内の値を成功させる'
			When call sx_num_is_int_fit 32 "2147483647" "-2147483648" "017777777777" "-020000000000" "0x7FFFFFFF" "-0x80000000"
			The status should be success
		End

		It '64bit の範囲内の値を成功させる'
			When call sx_num_is_int_fit 64 "9223372036854775807" "-9223372036854775808" "0777777777777777777777" "-01000000000000000000000" "0x7FFFFFFFFFFFFFFF" "-0x8000000000000000"
			The status should be success
		End

		It '128bit の範囲内の値を成功させる'
			When call sx_num_is_int_fit 128 "170141183460469231731687303715884105727" "-170141183460469231731687303715884105728"
			The status should be success
		End
	End

	Describe '範囲外の値'
		It '8bit の最大値を超える値で失敗する'
			When call sx_num_is_int_fit 8 "128"
			The status should be failure
		End

		It '8bit の最小値を下回る値で失敗する'
			When call sx_num_is_int_fit 8 "-129"
			The status should be failure
		End

		It '32bit の最大値を超える値で失敗する'
			When call sx_num_is_int_fit 32 "2147483648"
			The status should be failure
		End

		It '32bit の最小値を下回る値で失敗する'
			When call sx_num_is_int_fit 32 "-2147483649"
			The status should be failure
		End
	End

	Describe '無効なビット幅'
		It '不正なビット幅 10 で EX_USAGE を返す'
			When call sx_num_is_int_fit 10 "123"
			The status should equal 64
		End

		It '不正なビット幅 99 で EX_USAGE を返す'
			When call sx_num_is_int_fit 99 "123"
			The status should equal 64
		End
	End

	Describe 'デフォルト引数'
		It 'ビット幅のみ指定で成功する'
			When call sx_num_is_int_fit 64
			The status should be success
		End

		It '32bit で値 0 を成功させる'
			When call sx_num_is_int_fit 32 0
			The status should be success
		End
	End

	Describe '複数引数'
		It '複数の有効な値で成功する'
			When call sx_num_is_int_fit 32 "0" "1" "-1" "2147483647" "-2147483648"
			The status should be success
		End

		It 'いずれかが範囲外の場合に失敗する'
			When call sx_num_is_int_fit 32 "123" "2147483648"
			The status should be failure
		End
	End

	Describe '非整数'
		It '英字を含む値で失敗する'
			When call sx_num_is_int_fit 32 "abc"
			The status should be failure
		End

		It '無効な16進数で失敗する'
			When call sx_num_is_int_fit 32 "0xG"
			The status should be failure
		End

		It '8進数として無効な数字で失敗する'
			When call sx_num_is_int_fit 32 "08" "09"
			The status should be failure
		End

		It '空文字列で失敗する'
			When call sx_num_is_int_fit 32 ''
			The status should be failure
		End

		It '符号のみで失敗する'
			When call sx_num_is_int_fit 32 +
			The status should be failure
		End

		It '複数符号で失敗する'
			When call sx_num_is_int_fit 32 ++1
			The status should be failure
		End
	End
End
