# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh
# ShellSpecのParameters内の負数・範囲指定の診断を抑制する。
# shellcheck disable=SC2215,SC2288

Describe 'sx_arr_has -efu 環境検証'
    # shellcheck disable=SC2329
  setup_myarr_fixture() {
      sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d e
    }

  Include ./spec/support/setup.sh
  Include ./spec/support/library.sh sx_arr_has

  It '正常動作'
sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c

    When run efu_run sx_arr_has myarr 0
    The status should be success
  End

  It '範囲指定ができること'
sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d e

    When run efu_run sx_arr_has myarr 3:0:-1
    The status should be success
  End

  It '終端省略ができること'
sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d e

    When run efu_run sx_arr_has myarr 2::-1
    The status should be success
  End

  Context '32bit算術シェル専用の算術域境界 (NUM_RANGE=32)'
    Skip if '32bit算術シェル専用のため' arith_not32
    Before 'sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR -- "sx_cfg_set NUM_RANGE=32"'
    BeforeEach setup_myarr_fixture

    Parameters
      2147483647:0:-5 0
      2147483647:0:-6 0
      2147483647:0:-4 0
      -2147483653:10:1 0
      -2000000000:10:2000000000 1
      -2147483649:5:+2147483648 0
      4:0:-2147483648 0
      0:5:+2147483648 0
    End

    It "範囲 $1 の存在を-e下で判定すること"
      When run efu_run sx_arr_has myarr "$1"
      The status should equal "$2"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '算術域境界 (NUM_RANGE=64)'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64

    It 't<0 クランプの中間値が溢れないこと (始点D・step-5・境界)'
      setup_command='
        SX_SYS_REV=$1
        sx_cfg_set NUM_RANGE=64
        sx_arr_gen myarr a b c d e
      '
      sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR myarr SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      When run efu_run sx_arr_has myarr 9223372036854775807:0:-5
      The status should be success
    End

    It 't<0 クランプの中間値が溢れないこと (始点D・step-6)'
      setup_command='
        SX_SYS_REV=$1
        sx_cfg_set NUM_RANGE=64
        sx_arr_gen myarr a b c d e
      '
      sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR myarr SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      When run efu_run sx_arr_has myarr 9223372036854775807:0:-6
      The status should be success
    End

    It 't<0 クランプ境界 (|t|=4) は溢れずに解決すること'
      setup_command='
        SX_SYS_REV=$1
        sx_cfg_set NUM_RANGE=64
        sx_arr_gen myarr a b c d e
      '
      sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR myarr SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      When run efu_run sx_arr_has myarr 9223372036854775807:0:-4
      The status should be success
    End

    It '開始値が算術最小値でも正規化が溢れず全件を解決すること'
      setup_command='
        SX_SYS_REV=$1
        sx_cfg_set NUM_RANGE=64
        sx_arr_gen myarr a b c d e
      '
      sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR myarr SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      When run efu_run sx_arr_has myarr -9223372036854775813:10:1
      The status should be success
    End

    It '負始点と巨大正stepの正規化が溢れず空で終えること'
      setup_command='
        SX_SYS_REV=$1
        sx_cfg_set NUM_RANGE=64
        sx_arr_gen myarr a b c d e
      '
      sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR myarr SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      When run efu_run sx_arr_has myarr -9000000000000000000:10:9000000000000000000
      The status should equal 1
    End
  End
End