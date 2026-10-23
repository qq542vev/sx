#!/bin/sh
# shellcheck disable=SC2154 # 結果変数はライブラリと復元したデータが設定する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_splice の自己呼び出し依存検証'
	Include ./spec/support/prepare.sh

	Context '準備側'
		Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

		launch_splice_child() {
			# 準備はExampleの実行時だけ行う。列挙・dry-runでは読み込まない。
				sx_test_setup sx_arr_gen items a b c
				sx_test_setup sx_arr_gen special '' "space quote'" 'first
last
'
				sx_test_setup sx_var_dump fixture items special

			module_path=./build/modules/sx_arr_splice.sh

			case "${1}" in broken)
				module_path="${SHELLSPEC_WORKDIR}/splice-broken.sh"
				cp ./build/modules/sx_arr_splice.sh "${module_path}" || return
				printf '\nunset -f __sx_arr_splice_raw\n' >> "${module_path}"
			esac

			# 親のSX_*・SHELLSPEC_*を渡さず、入力と実行に必要な環境だけを渡す。
			# 子はこのファイルだけを実行し、親用Contextをスキップする。
			env -i PATH="${PATH}" HOME="${HOME}" LC_ALL="${LC_ALL:-${LANG:-C.UTF-8}}" \
				SXTEST_DEP_FIXTURE="${fixture}" SXTEST_DEP_MODULE="${module_path}" \
				shellspec --shell sh --jobs 0 --no-color --no-quick \
				--warning-as-failure --fail-no-examples --format documentation \
				"${SHELLSPEC_SPECFILE}"
		}

		It '単独モジュールで子の全検証が成功すること'
			When run launch_splice_child normal
			The status should be success
			# 子側の全件スキップも成功扱いにしない。親2件だけがスキップされる。
			The stdout should include '8 examples, 0 failures, 2 skips'
			The stderr should equal ''
		End

		It '依存欠落による子の失敗と診断が親へ伝わること'
			When run launch_splice_child broken
			The status should equal 101
			The stdout should include '__sx_arr_splice_raw'
			The stdout should not include '8 examples, 0 failures, 2 skips'
			The stderr should equal ''
		End
	End

	Context '単独モジュール側'
		Skip if '親プロセスでは子の検証を実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

		restore_splice_fixture() {
				case "${SXTEST_DEP_MODULE:?子の対象モジュールが未指定です}" in
					./build/modules/sx_arr_splice.sh)
						Include ./build/modules/sx_arr_splice.sh
						;;
					*)
						Include "${SXTEST_DEP_MODULE}"
						;;
				esac

			# 親のsx_var_dumpが生成した代入・unsetのみを復元する。
			eval "${SXTEST_DEP_FIXTURE}"
		}

		BeforeEach restore_splice_fixture

		It '空文字・引用符・末尾改行を復元できること'
			expected_tail='first
last
'
			The variable items_len should equal 3
			The variable items_0 should equal a
			The variable items_1 should equal b
			The variable items_2 should equal c
			The variable special_len should equal 3
			The variable special_0 should equal ''
			The variable special_1 should equal "space quote'"
			The variable special_2 should equal "$expected_tail"
		End

		It '中央の要素を置換できること'
			When call sx_arr_splice items 1 1 replacement
			The status should be success
			The variable items_len should equal 3
			The variable items_0 should equal a
			The variable items_1 should equal replacement
			The variable items_2 should equal c
		End

		It '挿入により後続要素を移動できること'
			When call sx_arr_splice items 1 0 x y
			The status should be success
			The variable items_len should equal 5
			The variable items_0 should equal a
			The variable items_1 should equal x
			The variable items_2 should equal y
			The variable items_3 should equal b
			The variable items_4 should equal c
		End

		It '削除により末尾の変数も解放できること'
			When call sx_arr_splice items 0 2
			The status should be success
			The variable items_len should equal 1
			The variable items_0 should equal c
			The variable items_1 should be undefined
			The variable items_2 should be undefined
		End

		It '検証省略の経路でも動作すること'
			SX_CFG_SKIP_CHK=1
			When call sx_arr_splice items 1 1 replacement
			The status should be success
			The variable items_len should equal 3
			The variable items_1 should equal replacement
		End

		It '-efuの実行経路でも動作すること'
			splice_and_check_leaks() {
				sx_arr_splice items 1 1 replacement
				check_no_leak
			}
			When run efu_run splice_and_check_leaks
			The status should be success
			The stdout should equal ''
			The stderr should equal ''
		End
	End
End
