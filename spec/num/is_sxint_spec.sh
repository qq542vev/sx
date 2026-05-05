#!/bin/sh

Describe 'sx_num_is_sxint'
  Include ./sx.sh

  Context 'デフォルト (32ビット)'
    It '32ビットの境界値を検証すること'
      When call sx_num_is_sxint "2147483647" "-2147483648"
      The status should be success
    End

    It '32ビットのオーバーフローを検出すること'
      When call sx_num_is_sxint "2147483648"
      The status should be failure
    End
  End

  Context '8ビット設定'
    Before 'SX_CFG_NUM_RANGE=8'
    It '8ビットの境界値を検証すること'
      When call sx_num_is_sxint "127" "-128"
      The status should be success
    End

    It '8ビットのオーバーフローを検出すること'
      When call sx_num_is_sxint "128"
      The status should be failure
    End
  End

  Context '64ビット設定'
    Before 'SX_CFG_NUM_RANGE=64'
    It '64ビットの境界値を検証すること'
      When call sx_num_is_sxint "9223372036854775807" "-9223372036854775808"
      The status should be success
    End

    It '64ビットのオーバーフローを検出すること'
      When call sx_num_is_sxint "9223372036854775808"
      The status should be failure
    End
  End

  Context '無効な設定（空または非数値）'
    Context '空の場合'
      Before 'SX_CFG_NUM_RANGE='
      It '設定エラーで失敗すること'
        When call sx_num_is_sxint "1"
        The status should equal 78
      End
    End

    Context '非数値の場合'
      Before 'SX_CFG_NUM_RANGE=abc'
      It '設定エラーで失敗すること'
        When call sx_num_is_sxint "1"
        The status should equal 78
      End
    End
  End
End
