#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_is_ebind'
  Include ./sx.sh

  It 'scalarとlistを含む拡張バインドを検証すること'
    When call sx_arr_is_ebind 'scalar:0/2list:0/3list'
    The status should be success
  End

  It '引数なしで成功すること'
    When call sx_arr_is_ebind
    The status should be success
  End

  It '割当数が上限以上のセグメントを拒否すること'
    When call sx_arr_is_ebind '2/2list'
    The status should be failure
  End

  It '同名変数を異なる型で再利用する形式を拒否すること'
    When call sx_arr_is_ebind 'arr:0/2arr'
    The status should be failure
  End

  It '配列参照記号 @ を含む形式を拒否すること'
    When call sx_arr_is_ebind '0/2@arr'
    The status should be failure
  End

  It '配列バインド形式でない記号を拒否すること'
    When call sx_arr_is_ebind 'arr-name'
    The status should be failure
  End

  It '不正な NUM_RANGE を検出すること'
    check_invalid_config() {
      SX_CFG_NUM_RANGE=99
      sx_arr_is_ebind '0/2list'
    }
    When call check_invalid_config
    The status should equal 78
  End
End
