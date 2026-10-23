#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# ShellSpec: Parameters内のパターン文字列を使用する。
# shellcheck disable=SC2288

eval "$(shellspec - -c) exit 1"


Describe 'sx_cfg_is_valid()'
	Include ./spec/support/setup.sh
	Include ./spec/support/library.sh sx_cfg_is_valid

	Context '生成されたパターンによる設定値の検査'
		Parameters
			'NUM_RANGE=32' 0
			'NUM_RANGE=64' 0
			'NUM_RANGE=128' 0
			'NUM_RANGE=064' 1
			'NUM_RANGE=64x' 1
			'NUM_RANGE=32|64|128' 1
			'SKIP_CHK=0' 0
			'SKIP_CHK=1' 0
			'SKIP_CHK=01' 1
			'ARR_UPDATE=0' 0
			'ARR_UPDATE=1' 0
			'ARR_UPDATE=2' 1
			'ARR_UPDATE=01' 1
			'SIG_ARR=x' 0
			'SEP=|' 0
			'ARR_HOLE=' 0
			'ARR_HOLE=32|64|128' 0
			'ARR_REF=' 0
			'ARR_REF=[01]' 0
			'32' 1
			'64' 1
			'128' 1
		End

		It "$1 を項目名と値の両方で検査すること"
			When call sx_cfg_is_valid "${1}"
			The status should equal "${2}"
			The stderr should equal ''
		End
	End

	It '正常な値をパスすること (NUM_RANGE=64)'
		When call sx_cfg_is_valid "NUM_RANGE=64"
		The status should be success
	End

	It '不正な値を拒否すること (NUM_RANGE=99)'
		When call sx_cfg_is_valid "NUM_RANGE=99"
		The status should be failure
		The status should equal 1
	End

	It '8ビットおよび16ビットを拒否すること'
		When call sx_cfg_is_valid "NUM_RANGE=8" "NUM_RANGE=16"
		The status should be failure
		The status should equal 1
	End

	It '正常な値をパスすること (SKIP_CHK=1)'
		When call sx_cfg_is_valid "SKIP_CHK=1"
		The status should be success
	End

	It '不正な値を拒否すること (SKIP_CHK=2)'
		When call sx_cfg_is_valid "SKIP_CHK=2"
		The status should be failure
	End

	It '空の値を拒否すること (SEP)'
		When call sx_cfg_is_valid "SEP="
		The status should equal 1
	End

	Context '廃止された SIG_BASE の拒否'
		Parameters
			'SIG_BASE'
			'SIG_BASE=custom'
			'SIG_BASE='
		End

		It "$1 を設定項目として認めないこと"
			When call sx_cfg_is_valid "${1}"
			The status should equal 1
		End
	End

	It '空の値を拒否すること (SIG_ARR)'
		When call sx_cfg_is_valid "SIG_ARR="
		The status should equal 1
	End

	It '引数なしで現在の設定を検査すること'
		SX_CFG_NUM_RANGE=32
		When call sx_cfg_is_valid
		The status should be success
	End

	Context '現在の設定の未設定と空文字の区別'
		Parameters
			'SX_CFG_SIG_ARR' 1
			'SX_CFG_SKIP_CHK' 1
			'SX_CFG_NUM_RANGE' 1
			'SX_CFG_SEP' 1
			'SX_CFG_ARR_UPDATE' 1
			'SX_CFG_ARR_HOLE' 0
			'SX_CFG_ARR_REF' 0
		End

		It "$1 が未設定なら引数なしの検査で1を返すこと"
			unset "${1}"
			When call sx_cfg_is_valid
			The status should equal 1
			The stderr should equal ''
			The variable "${1}" should be undefined
		End

		It "$1 が設定済みの空文字なら項目の規則に従って検査すること"
			eval "${1}="
			When call sx_cfg_is_valid
			The status should equal "${2}"
			The stderr should equal ''
			The variable "${1}" should equal ''
		End
	End

	It '引数なしの検査で設定値の空白と特殊文字を保持すること'
		sxtest_setup SX_CFG_SIG_ARR SX_CFG_SEP SX_CFG_ARR_HOLE SX_CFG_ARR_REF -- 'sx_cfg_set "$@"' 'SIG_ARR=custom array *' 'SEP=: : *' 'ARR_HOLE=hole *' 'ARR_REF=@ ref'
		When call sx_cfg_is_valid
		The status should be success
	End

	Context 'メタ情報の名前と旧既定値名の拒否'
		Parameters
			'META_NAMES'
			'META_DEF_SIG_ARR'
			'META_DESC_SIG_ARR'
			'META_PATTERN_NUM_RANGE'
			'META_OTHER'
			'DEF_SIG_ARR'
		End

		It "$1 を設定項目として認めないこと"
			When call sx_cfg_is_valid "${1}"
			The status should equal 1
		End
	End

	It '引数なしで異常な現在の設定を検知すること'
		SX_CFG_NUM_RANGE=99
		When call sx_cfg_is_valid
		The status should be failure
	End

	It 'プレフィックスありの指定は不正とみなされること (SX_CFG_...)'
		# SX_CFG_NUM_RANGE=64 と渡すと SX_CFG_SX_CFG_NUM_RANGE=64 として扱われる
		When call sx_cfg_is_valid "SX_CFG_NUM_RANGE=64"
		The status should be failure
		The status should equal 1
	End

	It '廃止された項目を拒否すること (UNSET_SOFT)'
		When call sx_cfg_is_valid "UNSET_SOFT"
		The status should be failure
		The status should equal 1
	End

	It '廃止された項目への値指定を拒否すること (UNSET_SOFT=0)'
		When call sx_cfg_is_valid "UNSET_SOFT=0"
		The status should be failure
		The status should equal 1
	End
End
