#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_has_idx'
  Include ./sx.sh
  BeforeEach 'sx_arr_gen myarr "a" "b" "c"'

  It '存在するインデックスに対して成功を返すこと'
    When call sx_arr_has_idx myarr 0
    The status should be success
  End

  It '複数の存在するインデックスに対して成功を返すこと'
    When call sx_arr_has_idx myarr 0 1 2
    The status should be success
  End

  It '範囲外のインデックスに対して失敗を返すこと'
    When call sx_arr_has_idx myarr 3
    The status should be failure
  End

  It '一部が範囲外の場合に失敗を返すこと'
    When call sx_arr_has_idx myarr 1 4
    The status should be failure
  End

  It '空の配列に対してインデックス 0 は失敗を返すこと'
    sx_arr_gen empty_arr
    When call sx_arr_has_idx empty_arr 0
    The status should be failure
  End

  It '配列ではない変数に対して EX_DATAERR を返すこと'
    not_arr="not an array"
    When call sx_arr_has_idx not_arr 0
    The status should equal 65
  End

  It '数値ではないインデックスに対して EX_USAGE を返すこと'
    When call sx_arr_has_idx myarr "len"
    The status should equal 64
  End

  It 'インデックスが指定されない場合は成功を返すこと'
    When call sx_arr_has_idx myarr
    The status should be success
  End

  It 'SX_CFG_SKIP_CHK=1 の場合でも正しく動作すること'
    SX_CFG_SKIP_CHK=1
    When call sx_arr_has_idx myarr 0 1 2
    The status should be success
  End

  It 'SX_CFG_SKIP_CHK=1 の場合でも範囲外なら失敗を返すこと'
    SX_CFG_SKIP_CHK=1
    When call sx_arr_has_idx myarr 3
    The status should be failure
  End
End
