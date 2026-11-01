#!/bin/sh
# shellcheck shell=sh

Describe 'sx_str_tr_args -efu 環境検証'
  sxtest_load ./build/modules/sx_str_tr_args.sh

  Context 'limitと検証省略'
    Parameters
      0 ''
      0 0
      0 -0
      0 2
      0 -2
      0 -999999999999999999999999999999
      1 ''
      1 0
      1 -0
      1 2
      1 -2
      1 -999999999999999999999999999999
    End

    It '外部コマンドなしで処理すること'
      SX_CFG_SKIP_CHK=$1
      When run efu_run sx_str_tr_args res:cnt a1b2c3 abc "$2" ::: AA '' CC
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '引数不足をシェルエラーにせず64で拒否すること'
    When run efu_run sx_str_tr_args
    The status should equal 64
    The stderr should equal ''
  End

  It '不正なlimitを64で拒否すること'
    When run efu_run sx_str_tr_args res:cnt ab ab 01 ::: AA BB
    The status should equal 64
    The stderr should equal ''
  End

  It '置換先省略でも位置パラメータの未設定を参照しないこと'
    When run efu_run sx_str_tr_args res:cnt ab ab
    The status should be success
    The stderr should equal ''
  End
End
