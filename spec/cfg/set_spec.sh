#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# ShellSpec: 参照渡しで設定される変数を使用する。
# shellcheck disable=SC2154

eval "$(shellspec - -c) exit 1"


Describe 'sx_cfg_set()'
	# Exampleごとに対象だけを読み込む。
	load_subject() {
		case "$1" in
			sx_cfg_set)
				sxtest_load ./build/modules/sx_cfg_set.sh
				;;
			__sx_cfg_set)
				sxtest_load ./build/modules/__sx_cfg_set.sh
				;;
			*) return 64;;
		esac
	}

	Include ./spec/support/run.sh

	cfg_set_custom() {
		sxtest_run SX_CFG_SIG_ARR SX_CFG_NUM_RANGE SX_CFG_SEP SX_CFG_ARR_UPDATE SX_CFG_ARR_HOLE SX_CFG_ARR_REF SX_CFG_SKIP_CHK SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR SX_SYS_NUM_MAX SX_SYS_NUM_MIN -- 'sx_cfg_set "$@"' SIG_ARR=custom-array NUM_RANGE=64 \
			SEP=@@ ARR_UPDATE=0 ARR_HOLE=hole ARR_REF=@ "SKIP_CHK=${1-0}"
	}

	cfg_with_ifs() {
		cfg_saved_ifs=${IFS}
		IFS='_:'
		"${@}"
		set -- "${?}" "${cfg_saved_ifs}"
		IFS=${2}
		unset cfg_saved_ifs
		return "${1}"
	}

	Context '引数なしの全設定リセット'
		Parameters
			'sx_cfg_set' 0
			'sx_cfg_set' 1
			'__sx_cfg_set' 0
			'__sx_cfg_set' 1
		End

		It "$1 が SKIP_CHK=$2 から全設定と数値派生値を既定値に戻すこと"
			load_subject "$1"
			cfg_set_custom "${2}"
			When call "${1}"
			The status should be success
			The variable SX_CFG_SIG_ARR should equal "${SX_CFG_META_DEF_SIG_ARR}"
			The variable SX_CFG_SKIP_CHK should equal "${SX_CFG_META_DEF_SKIP_CHK}"
			The variable SX_CFG_NUM_RANGE should equal "${SX_CFG_META_DEF_NUM_RANGE}"
			The variable SX_CFG_SEP should equal "${SX_CFG_META_DEF_SEP}"
			The variable SX_CFG_ARR_UPDATE should equal "${SX_CFG_META_DEF_ARR_UPDATE}"
			The variable SX_CFG_ARR_HOLE should equal "${SX_CFG_META_DEF_ARR_HOLE}"
			The variable SX_CFG_ARR_REF should equal "${SX_CFG_META_DEF_ARR_REF}"
			The variable SX_SYS_NUM_WLEN should equal "${SX_NUM_I32_WLEN}"
			The variable SX_SYS_NUM_QM should equal "${SX_NUM_I32_QM}"
			The variable SX_SYS_NUM_ZR should equal "${SX_NUM_I32_ZR}"
			The variable SX_SYS_NUM_MAX should equal "${SX_NUM_I32_MAX}"
			The variable SX_SYS_NUM_MIN should equal "${SX_NUM_I32_MIN}"
		End
	End

	It '全設定リセットを繰り返しても成功すること'
		load_subject sx_cfg_set
		cfg_set_custom
		sx_cfg_set
		When call sx_cfg_set
		The status should be success
		The variable SX_CFG_SIG_ARR should equal "${SX_CFG_META_DEF_SIG_ARR}"
		The variable SX_CFG_NUM_RANGE should equal "${SX_CFG_META_DEF_NUM_RANGE}"
	End

	Context 'IFS に依存しない全設定リセット'
		Parameters
			0
			1
		End

		It "SKIP_CHK=$1 で IFS を変更しても全設定を既定値に戻せること"
			load_subject sx_cfg_set
			cfg_set_custom "${1}"
			When call cfg_with_ifs sx_cfg_set
			The status should be success
			The variable SX_CFG_SIG_ARR should equal "${SX_CFG_META_DEF_SIG_ARR}"
			The variable SX_CFG_SKIP_CHK should equal "${SX_CFG_META_DEF_SKIP_CHK}"
			The variable SX_CFG_NUM_RANGE should equal "${SX_CFG_META_DEF_NUM_RANGE}"
			The variable SX_CFG_SEP should equal "${SX_CFG_META_DEF_SEP}"
			The variable SX_CFG_ARR_UPDATE should equal "${SX_CFG_META_DEF_ARR_UPDATE}"
			The variable SX_CFG_ARR_HOLE should equal "${SX_CFG_META_DEF_ARR_HOLE}"
			The variable SX_CFG_ARR_REF should equal "${SX_CFG_META_DEF_ARR_REF}"
		End
	End

	Context 'メタ情報の設定の拒否'
		Parameters
			'META_NAMES'
			'META_DEF_SIG_ARR'
			'META_DESC_SIG_ARR'
			'META_PATTERN_NUM_RANGE'
			'META_OTHER'
			'META_NAMES=invalid'
			'META_DEF_SIG_ARR=invalid'
			'META_DESC_SIG_ARR=invalid'
			'META_PATTERN_NUM_RANGE=invalid'
		End

		It "$1 を64で拒否し、他の設定も変更しないこと"
			load_subject sx_cfg_set
			cfg_set_custom
			When call sx_cfg_set NUM_RANGE=32 "${1}"
			The status should equal 64
			The stderr should equal ''
			The variable SX_CFG_NUM_RANGE should equal 64
			The variable SX_CFG_SIG_ARR should equal custom-array
		End
	End

	It '全設定リセットでリビジョンと既存配列のデータを変更しないこと'
		load_subject sx_cfg_set
		cfg_set_custom
		SX_SYS_REV=${SX_SYS_REV-0}
		sxtest_run "SX_CFG_SIG_ARR=$SX_CFG_SIG_ARR" cfg_existing SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" cfg_existing first ''
		cfg_existing_sig=${cfg_existing}
		cfg_existing_rev=${SX_SYS_REV}
		When call sx_cfg_set
		The status should be success
		The variable SX_SYS_REV should equal "${cfg_existing_rev}"
		The variable cfg_existing should equal "${cfg_existing_sig}"
		The variable cfg_existing_len should equal 2
		The variable cfg_existing_0 should equal first
		The variable cfg_existing_1 should equal ''
	End

	Context '全変更対象の書込可否の事前検査'
		Parameters
			'SX_CFG_SIG_ARR'
			'SX_CFG_SKIP_CHK'
			'SX_CFG_NUM_RANGE'
			'SX_CFG_SEP'
			'SX_CFG_ARR_UPDATE'
			'SX_CFG_ARR_HOLE'
			'SX_CFG_ARR_REF'
			'SX_SYS_NUM_WLEN'
			'SX_SYS_NUM_QM'
			'SX_SYS_NUM_ZR'
			'SX_SYS_NUM_MAX'
			'SX_SYS_NUM_MIN'
		End

		It "$1 が readonly なら77を返し、設定と数値派生値を変更しないこと"
			load_subject sx_cfg_set
			cfg_set_custom
			readonly "${1}"
			When call sx_cfg_set
			The status should equal 77
			The stderr should equal ''
			The variable SX_CFG_SIG_ARR should equal custom-array
			The variable SX_CFG_SKIP_CHK should equal 0
			The variable SX_CFG_NUM_RANGE should equal 64
			The variable SX_CFG_SEP should equal @@
			The variable SX_CFG_ARR_UPDATE should equal 0
			The variable SX_CFG_ARR_HOLE should equal hole
			The variable SX_CFG_ARR_REF should equal @
			The variable SX_SYS_NUM_WLEN should equal "${SX_NUM_I64_WLEN}"
			The variable SX_SYS_NUM_QM should equal "${SX_NUM_I64_QM}"
			The variable SX_SYS_NUM_ZR should equal "${SX_NUM_I64_ZR}"
			The variable SX_SYS_NUM_MAX should equal "${SX_NUM_I64_MAX}"
			The variable SX_SYS_NUM_MIN should equal "${SX_NUM_I64_MIN}"
		End
	End

	It '数値派生値が readonly なら NUM_RANGE の変更前に77を返すこと'
		load_subject sx_cfg_set
		cfg_set_custom
		readonly SX_SYS_NUM_MAX
		When call sx_cfg_set NUM_RANGE
		The status should equal 77
		The stderr should equal ''
		The variable SX_CFG_SIG_ARR should equal custom-array
		The variable SX_CFG_NUM_RANGE should equal 64
		The variable SX_SYS_NUM_MAX should equal "${SX_NUM_I64_MAX}"
	End

	It '署名と数値範囲を正常に設定できること'
		load_subject sx_cfg_set
		When call sx_cfg_set "SIG_ARR=new-sig" "NUM_RANGE=64"
		The status should be success
		The variable SX_CFG_SIG_ARR should equal 'new-sig'
		The variable SX_CFG_NUM_RANGE should equal 64
	End

	It '値をデフォルトにリセットできること'
		load_subject sx_cfg_set
		SX_CFG_NUM_RANGE=64
		When call sx_cfg_set "NUM_RANGE"
		The status should be success
		The variable SX_CFG_NUM_RANGE should equal 32
	End

	It '署名を個別に既定値に戻せること'
		load_subject sx_cfg_set
		sx_cfg_set SIG_ARR=custom-array
		When call sx_cfg_set "SIG_ARR"
		The status should be success
		The variable SX_CFG_SIG_ARR should equal "${SX_CFG_META_DEF_SIG_ARR}"
	End

	Context '廃止された SIG_BASE の拒否'
		Parameters
			'SIG_BASE'
			'SIG_BASE=custom'
			'SIG_BASE='
		End

		It "$1 を64で拒否し、他の設定も変更しないこと"
			load_subject sx_cfg_set
			cfg_set_custom
			When call sx_cfg_set NUM_RANGE=32 "${1}"
			The status should equal 64
			The variable SX_CFG_SIG_ARR should equal custom-array
			The variable SX_CFG_NUM_RANGE should equal 64
		End
	End

	It '独自署名の設定が配列生成に反映されること'
		load_subject sx_cfg_set
		When call sx_cfg_set SIG_ARR=custom-array
		The status should be success
		sxtest_run "SX_CFG_SIG_ARR=$SX_CFG_SIG_ARR" cfg_custom_arr -- 'sx_arr_gen cfg_custom_arr first second'
		The variable cfg_custom_arr should start with 'custom-array:'
		The variable cfg_custom_arr_len should equal 2
		The variable cfg_custom_arr_0 should equal first
		The variable cfg_custom_arr_1 should equal second
	End

	It '一つでも不正な値があれば、何も設定しないこと'
		load_subject sx_cfg_set
		SX_CFG_NUM_RANGE=32
		When call sx_cfg_set "NUM_RANGE=64" "SKIP_CHK=invalid"
		The status should be failure
		The variable SX_CFG_NUM_RANGE should equal 32
	End

	xIt 'SKIP_CHK=1 の時はバリデーションをバイパスすること'
		load_subject sx_cfg_set
		SX_CFG_SKIP_CHK=1
		When call sx_cfg_set "NUM_RANGE=999"
		The status should be success
		The variable SX_CFG_NUM_RANGE should equal 999
	End

	It '読み取り専用変数の場合はエラーを返すこと'
		load_subject sx_cfg_set
		readonly SX_CFG_NUM_RANGE=32
		When call sx_cfg_set "NUM_RANGE=64"
		The status should equal "77"
		The variable SX_CFG_NUM_RANGE should equal 32
	End
End
