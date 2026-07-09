#!/bin/sh

Describe 'sx_num_is_sx_nat1'
  Include ./sx.sh

  Context 'デフォルト (32ビット)'
    It '32ビットの正の境界値を検証すること'
      When call sx_num_is_sx_nat1 "2147483647" "1"
      The status should be success
    End

    It '0は失敗すること'
      When call sx_num_is_sx_nat1 "0"
      The status should be failure
    End

    It '負数は失敗すること'
      When call sx_num_is_sx_nat1 "-1" "-2147483648"
      The status should be failure
    End

    It '32ビットのオーバーフローを検出すること'
      When call sx_num_is_sx_nat1 "2147483648"
      The status should be failure
    End
  End

  Context 'SKIP_CHK フラグ'
    Before 'SX_CFG_SKIP_CHK=1'
    It '引数の検証自体は行われること'
      When call sx_num_is_sx_nat1 "abc"
      The status should be failure
    End


  End

  Context '無効な設定'
    Before 'SX_CFG_NUM_RANGE=abc'
    It '設定エラーで失敗すること'
      When call sx_num_is_sx_nat1 "1"
      The status should equal 78
    End

    It '不正な数値で設定エラーになること'
      SX_CFG_NUM_RANGE=9
      When call sx_num_is_sx_nat1 "1"
      The status should equal 78
    End
  End
End
