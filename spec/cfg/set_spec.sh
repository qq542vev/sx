# shellcheck shell=sh

Describe 'sx_cfg_set()'
	Include ./sx.sh

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
