#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_div_nat0'
  Include ./sx.sh

  # ホストの算術展開が 64bit 未満か判定する（32bit ホストでは 2^31 超の演算が致命的 overflow になるため）
  arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }

  It '小数部を求める除算ができること'
    When call sx_num_div_nat0 d 2 100 3
    The status should be success
    The variable d should equal "33.33"
  End

  It '小数部の末尾0を除去すること'
    When call sx_num_div_nat0 d 2 5 10
    The status should be success
    The variable d should equal "0.5"
  End

  It '小数部が1桁未満の場合にゼロ埋めされること'
    When call sx_num_div_nat0 d 2 101 100
    The status should be success
    The variable d should equal "1.01"
  End

  It '小数が0の場合は小数部を付けないこと'
    When call sx_num_div_nat0 d 1 1001 1000
    The status should be success
    The variable d should equal "1"
  End

  It '除算が割り切れる場合は小数部を付けないこと'
    When call sx_num_div_nat0 d 2 100 4
    The status should be success
    The variable d should equal "25"
  End

  It '小数桁数が複数桁の末尾0除去ができること'
    When call sx_num_div_nat0 d 4 7 2
    The status should be success
    The variable d should equal "3.5"
  End

  It '小数桁数が0の場合は実数商=整数商になること'
    When call sx_num_div_nat0 d 0 100 3
    The status should be success
    The variable d should equal "33"
  End

  It '被除数が0の場合の除算ができること'
    When call sx_num_div_nat0 d 2 0 5
    The status should be success
    The variable d should equal "0"
  End

  It '除数を省略した場合は除数1として扱われること'
    When call sx_num_div_nat0 d 2 5
    The status should be success
    The variable d should equal "5"
  End

  It '全引数を省略した場合は0になること'
    When call sx_num_div_nat0 d
    The status should be success
    The variable d should equal "0"
  End

  It '複数の除数を乗算して除算できること'
    When call sx_num_div_nat0 d 3 100 2 5
    The status should be success
    The variable d should equal "10"
  End

  It '複数の除数で小数部を求める除算ができること'
    When call sx_num_div_nat0 d 2 100 3 2
    The status should be success
    The variable d should equal "16.66"
  End

  It '一般パスで小数部を求める除算ができること'
    When call sx_num_div_nat0 d 3 192837465564738291019283746 98765432101
    The status should be success
    The variable d should equal "1952479338798800.351"
  End

  It '末尾ゼロ分解を経由する除算で小数部を求めることができること'
    When call sx_num_div_nat0 d 4 12345678900000000000123456789 123400000000
    The status should be success
    The variable d should equal "100046020259319286.8729"
  End

  Context '64ビット設定'
    Before 'SX_CFG_NUM_RANGE=64'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64

    It '一般パスで小数部を求める除算ができること'
      When call sx_num_div_nat0 d 10 123456789012345678901234567890 1234567890123456789
      The status should be success
      The variable d should equal "100000000000.0000000009"
    End
  End

  It 'ゼロ除算でエラー(64)になること'
    When call sx_num_div_nat0 d 2 100 0
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合にエラー(77)になること'
    readonly ro_res_int_div_abs="const"
    When call sx_num_div_nat0 ro_res_int_div_abs 2 100 3
    The status should equal 77
  End

  It '設定エラー(78)を検知すること'
    check_config() {
      SX_CFG_NUM_RANGE=99
      sx_num_div_nat0 d 2 100 3
    }
    When call check_config
    The status should equal 78
  End

  It '小数桁数が不適切な場合はエラー(64)になること'
    When call sx_num_div_nat0 d abc 100 3
    The status should equal 64
  End

  It '被除数が負数の場合はエラー(64)になること'
    When call sx_num_div_nat0 d 2 -5 3
    The status should equal 64
  End

  It '負数の除数を含む場合はエラー(64)になること'
    When call sx_num_div_nat0 d 2 100 -3
    The status should equal 64
  End

  It '非数値の除数を含む場合はエラー(64)になること'
    When call sx_num_div_nat0 d 2 100 abc
    The status should equal 64
  End
End