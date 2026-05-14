# shellcheck shell=sh

Describe 'CFG (Configuration)'
	BeforeRun 'm4 sx.m4 > s.sh'
	Include ./s.sh

	Describe 'sx_cfg_chk()'
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

	Describe 'sx_cfg_set()'
		It '値を正常に設定し、SIG_ARRを更新すること'
			When call sx_cfg_set "SIG_BASE=new-sig" "NUM_RANGE=64"
			The status should be success
			The variable SX_CFG_SIG_BASE should equal 'new-sig'
			The variable SX_CFG_SIG_ARR should equal 'array-new-sig'
			The variable SX_CFG_NUM_RANGE should equal 64
		End

		It '値をデフォルトにリセットできること'
			SX_CFG_NUM_RANGE=64
			When call sx_cfg_set "NUM_RANGE"
			The status should be success
			The variable SX_CFG_NUM_RANGE should equal 32
		End

		It 'SIG_BASEをリセットした時にSIG_ARRもデフォルトに戻ること'
			SX_CFG_SIG_BASE="custom"
			SX_CFG_SIG_ARR="array-custom"
			When call sx_cfg_set "SIG_BASE"
			The status should be success
			The variable SX_CFG_SIG_BASE should equal 'sx-sig-27c9d9d5-763d-4c3e-862d-a2f270928a38-5f8a2b1c'
			The variable SX_CFG_SIG_ARR should equal 'array-sx-sig-27c9d9d5-763d-4c3e-862d-a2f270928a38-5f8a2b1c'
		End

		It '一つでも不正な値があれば、何も設定しないこと'
			SX_CFG_NUM_RANGE=32
			When call sx_cfg_set "NUM_RANGE=64" "SKIP_CHK=invalid"
			The status should be failure
			The variable SX_CFG_NUM_RANGE should equal 32
		End

		It 'SKIP_CHK=1 の時はバリデーションをバイパスすること'
			SX_CFG_SKIP_CHK=1
			When call sx_cfg_set "NUM_RANGE=999"
			The status should be success
			The variable SX_CFG_NUM_RANGE should equal 999
		End

		It '読み取り専用変数の場合はエラーを返すこと'
			readonly SX_CFG_NUM_RANGE=32
			When call sx_cfg_set "NUM_RANGE=64"
			The status should equal "${SX_EX_NOPERM}"
			The variable SX_CFG_NUM_RANGE should equal 32
		End
	End
End
