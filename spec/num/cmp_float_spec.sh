#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_cmp_float'
	Include ./sx.sh

	It 'returns 1 when LHS < RHS'
		When call sx_num_cmp_float 1.2 3.4
		The status should equal 1
	End

	It 'returns 2 when LHS == RHS'
		When call sx_num_cmp_float 1.23 1.23
		The status should equal 2
	End

	It 'returns 3 when LHS > RHS'
		When call sx_num_cmp_float 3.4 1.2
		The status should equal 3
	End

	It 'handles negative numbers correctly'
		When call sx_num_cmp_float -1.2 -3.4
		The status should equal 3
	End

	It 'handles different number of decimal places'
		When call sx_num_cmp_float 1.2 1.200
		The status should equal 2
	End

	It 'handles exponential notation'
		When call sx_num_cmp_float 1e2 100
		The status should equal 2
	End

	It 'returns 64 for invalid inputs'
		When call sx_num_cmp_float abc 1.2
		The status should equal 64
	End

	It 'skips check when SX_CFG_SKIP_CHK is 1'
		SX_CFG_SKIP_CHK=1
		When call sx_num_cmp_float 1.2 3.4
		The status should equal 1
	End
End
