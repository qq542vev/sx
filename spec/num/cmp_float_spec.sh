#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_cmp_float'
	Include ./sx.sh

	It 'LHS < RHS の場合に 1 を返すこと'
		When call sx_num_cmp_float 1.2 3.4
		The status should equal 1
	End

	It 'LHS == RHS の場合に 2 を返すこと'
		When call sx_num_cmp_float 1.23 1.23
		The status should equal 2
	End

	It 'LHS > RHS の場合に 3 を返すこと'
		When call sx_num_cmp_float 3.4 1.2
		The status should equal 3
	End

	It '負の数値を正しく処理できること'
		When call sx_num_cmp_float -1.2 -3.4
		The status should equal 3
	End

	It '小数位の数が異なる場合を正しく処理できること'
		When call sx_num_cmp_float 1.2 1.200
		The status should equal 2
	End

	It '指数表記を正しく処理できること'
		When call sx_num_cmp_float 1e2 100
		The status should equal 2
	End

	It '無効な入力に対して 64 を返すこと'
		When call sx_num_cmp_float abc 1.2
		The status should equal 64
	End

	It 'SX_CFG_SKIP_CHK が 1 の時にチェックをスキップすること'
		SX_CFG_SKIP_CHK=1
		When call sx_num_cmp_float 1.2 3.4
		The status should equal 1
	End

	It '指数表記の非常に大きな値を比較できること'
		When call sx_num_cmp_float "1e100" "1e100"
		The status should equal 2
	End

	It '非常に小さな値を比較できること'
		When call sx_num_cmp_float "1e-100" "2e-100"
		The status should equal 1
	End

	It 'DBL_MAX境界の値を比較できること'
		When call sx_num_cmp_float "${SX_NUM_DBL_MAX}" "${SX_NUM_DBL_MAX}"
		The status should equal 2
	End
End
