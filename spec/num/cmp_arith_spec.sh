#!/bin/sh
# shellcheck disable=SC2154 # 結果変数は準備用シェルのダンプから復元する。
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_cmp_arith'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_num_cmp_arith.sh

  setup_num_range() {
    sxtest_run SX_CFG_NUM_RANGE setup_num_min setup_num_max -- \
      'sx_cfg_set "NUM_RANGE=$1"; setup_num_min=$SX_SYS_NUM_MIN; setup_num_max=$SX_SYS_NUM_MAX' "$1"
  }

  It 'LHS < RHS の場合に 1 を返すこと'
    When call sx_num_cmp_arith 10 20
    The status should equal 1
  End

  It 'LHS == RHS の場合に 2 を返すこと'
    When call sx_num_cmp_arith 15 15
    The status should equal 2
  End

  It 'LHS > RHS の場合に 3 を返すこと'
    When call sx_num_cmp_arith 30 20
    The status should equal 3
  End

  It '8進数を正しく処理できること'
    When call sx_num_cmp_arith 010 8
    The status should equal 2
  End

  It '16進数を正しく処理できること'
    When call sx_num_cmp_arith 0x10 16
    The status should equal 2
  End

  It '整数以外の入力に対して 64 を返すこと'
    When call sx_num_cmp_arith 1.5 2
    The status should equal 64
  End

  It '数値以外の入力に対して 64 を返すこと'
    When call sx_num_cmp_arith "abc" 10
    The status should equal 64
  End

  It 'SX_CFG_SKIP_CHK が 1 の時にチェックをスキップすること'
    SX_CFG_SKIP_CHK=1
    When call sx_num_cmp_arith 10 20
    The status should equal 1
  End

  It '巨大な値（INT32_MAX境界）を比較できること'
    When call sx_num_cmp_arith 2147483647 2147483647
    The status should equal 2
  End

  It '符号付きゼロ（+0, -0）を比較できること'
    When call sx_num_cmp_arith "-0" "+0"
    The status should equal 2
  End

  It '8進数と16進数の混合比較ができること'
    When call sx_num_cmp_arith "010" "0x8"
    The status should equal 2
  End

  Context '32bit算術シェル専用の最小値'
    # 64bit 未満のホストでは、設定幅が算術域を超えるため検証しない。
    Skip if '32bit算術シェル専用のため' arith_not32
    Before 'setup_num_range 32'

    It 'MIN < 0 の場合に 1 を返すこと'
      When call sx_num_cmp_arith "${setup_num_min}" 0
      The status should equal 1
    End

    It '0 > MIN の場合に 3 を返すこと'
      When call sx_num_cmp_arith 0 "${setup_num_min}"
      The status should equal 3
    End

    It 'MIN 同士の比較で 2 を返すこと'
      When call sx_num_cmp_arith "${setup_num_min}" "${setup_num_min}"
      The status should equal 2
    End

    It 'MIN < MAX の場合に 1 を返すこと'
      When call sx_num_cmp_arith "${setup_num_min}" "${setup_num_max}"
      The status should equal 1
    End

    It 'MIN < MIN + 1 の場合に 1 を返すこと'
      When call sx_num_cmp_arith "${setup_num_min}" -2147483647
      The status should equal 1
    End

    It 'チェックをスキップしても MIN を比較できること'
      SX_CFG_SKIP_CHK=1
      When call sx_num_cmp_arith "${setup_num_min}" 0
      The status should equal 1
    End
  End

  Context '64ビット設定の最小値'
    # 64bit 未満のホストでは、設定幅が算術域を超えるため検証しない。
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'setup_num_range 64'

    It 'MIN < 0 の場合に 1 を返すこと'
      When call sx_num_cmp_arith "${setup_num_min}" 0
      The status should equal 1
    End

    It '0 > MIN の場合に 3 を返すこと'
      When call sx_num_cmp_arith 0 "${setup_num_min}"
      The status should equal 3
    End

    It 'MIN 同士の比較で 2 を返すこと'
      When call sx_num_cmp_arith "${setup_num_min}" "${setup_num_min}"
      The status should equal 2
    End

    It 'MIN < MAX の場合に 1 を返すこと'
      When call sx_num_cmp_arith "${setup_num_min}" "${setup_num_max}"
      The status should equal 1
    End

    It 'MIN < MIN + 1 の場合に 1 を返すこと'
      When call sx_num_cmp_arith "${setup_num_min}" -9223372036854775807
      The status should equal 1
    End

    It 'チェックをスキップしても MIN を比較できること'
      SX_CFG_SKIP_CHK=1
      When call sx_num_cmp_arith "${setup_num_min}" 0
      The status should equal 1
    End
  End
End
