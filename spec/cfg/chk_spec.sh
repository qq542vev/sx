# shellcheck shell=sh

Describe 'sx_cfg_chk()'
	BeforeRun 'm4 sx.m4 > s.sh'
	Include ./s.sh

	It '正常な値をパスすること (NUM_RANGE=64)'
		When call sx_cfg_chk "NUM_RANGE=64"
		The status should be success
	End

	It '不正な値を拒否すること (NUM_RANGE=99)'
		When call sx_cfg_chk "NUM_RANGE=99"
		The status should be failure
		The status should equal 1
	End

	It '正常な値をパスすること (SKIP_CHK=1)'
		When call sx_cfg_chk "SKIP_CHK=1"
		The status should be success
	End

	It '不正な値を拒否すること (SKIP_CHK=2)'
		When call sx_cfg_chk "SKIP_CHK=2"
		The status should be failure
	End

	It '空の値を拒否すること (SEP)'
		When call sx_cfg_chk "SEP="
		The status should equal 1
	End

	It '空の値を拒否すること (SIG_BASE)'
		When call sx_cfg_chk "SIG_BASE="
		The status should equal 1
	End

	It '空の値を拒否すること (SIG_ARR)'
		When call sx_cfg_chk "SIG_ARR="
		The status should equal 1
	End

	It '引数なしで現在の設定を検査すること'
		SX_CFG_NUM_RANGE=32
		When call sx_cfg_chk
		The status should be success
	End

	It '引数なしで異常な現在の設定を検知すること'
		SX_CFG_NUM_RANGE=99
		When call sx_cfg_chk
		The status should be failure
	End

	It 'プレフィックスありの指定は不正とみなされること (SX_CFG_...)'
		# SX_CFG_NUM_RANGE=64 と渡すと SX_CFG_SX_CFG_NUM_RANGE=64 として扱われる
		# 未知の項目は現状パスするが、SIG_BASE などの依存関係は壊れない
		When call sx_cfg_chk "SX_CFG_NUM_RANGE=64"
		The status should be failure
		The status should equal 1
	End
End
