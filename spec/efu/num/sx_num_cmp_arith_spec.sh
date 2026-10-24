# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck disable=SC2154 # 結果変数は準備用シェルのダンプから復元する。
Describe 'sx_num_cmp_arith -efu 環境検証'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_num_cmp_arith.sh

  setup_num_range() {
    sxtest_run SX_CFG_NUM_RANGE setup_num_min setup_num_max -- \
      'sx_cfg_set "NUM_RANGE=$1"; setup_num_min=$SX_SYS_NUM_MIN; setup_num_max=$SX_SYS_NUM_MAX' "$1"
  }

  It '正常動作'
    When run efu_run sx_num_cmp_arith 5 5
    The status should equal 2
  End

  Context '32bit算術シェル専用の最小値'
    Skip if '32bit算術シェル専用のため' arith_not32
    Before 'setup_num_range 32'

    It 'MIN を左辺として比較できること'
      When run efu_run sx_num_cmp_arith "${setup_num_min}" 0
      The status should equal 1
    End

    It 'MIN を右辺として比較できること'
      When run efu_run sx_num_cmp_arith 0 "${setup_num_min}"
      The status should equal 3
    End

    It 'MIN 同士を比較できること'
      When run efu_run sx_num_cmp_arith "${setup_num_min}" "${setup_num_min}"
      The status should equal 2
    End
  End

  Context '64ビット設定の最小値'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'setup_num_range 64'

    It 'MIN を左辺として比較できること'
      When run efu_run sx_num_cmp_arith "${setup_num_min}" 0
      The status should equal 1
    End

    It 'MIN を右辺として比較できること'
      When run efu_run sx_num_cmp_arith 0 "${setup_num_min}"
      The status should equal 3
    End

    It 'MIN 同士を比較できること'
      When run efu_run sx_num_cmp_arith "${setup_num_min}" "${setup_num_min}"
      The status should equal 2
    End
  End
End
