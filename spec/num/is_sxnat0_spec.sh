#!/bin/sh

Describe 'sx_num_is_sxnat0'
  Include ./sx.sh

  Context 'デフォルト (32ビット)'
    It '32ビットの正の境界値を検証すること'
      When call sx_num_is_sxnat0 "2147483647" "0"
      The status should be success
    End

    It '負数は失敗すること'
      When call sx_num_is_sxnat0 "-1" "-2147483648"
      The status should be failure
    End

    It '32ビットのオーバーフローを検出すること'
      When call sx_num_is_sxnat0 "2147483648"
      The status should be failure
    End
  End

  Context '8ビット設定'
    Before 'SX_CFG_NUM_RANGE=8'
    It '8ビットの正の境界値を検証すること'
      When call sx_num_is_sxnat0 "127" "0"
      The status should be success
    End

    It '8ビットのオーバーフローを検出すること'
      When call sx_num_is_sxnat0 "128"
      The status should be failure
    End
  End

  Context 'SKIP_CHK フラグ'
    Before 'SX_CFG_SKIP_CHK=1'
    It '引数の検証自体は行われること'
      When call sx_num_is_sxnat0 "abc"
      The status should be failure
    End

    It '設定が不正でも環境チェックをスキップすること'
      # SX_CFG_NUM_RANGE=9 は sx_cfg_chk では不正とされる
      SX_CFG_NUM_RANGE=9
      # 本来なら sx_cfg_chk で 78 (SX_EX_CONFIG) になるが、
      # SKIP_CHK=1 なのでそれを飛ばして内部処理に進む。
      When call sx_num_is_sxnat0 "0"
      The status should not equal 78
    End
  End

  Context '無効な設定'
    Before 'SX_CFG_NUM_RANGE=abc'
    It '設定エラーで失敗すること'
      When call sx_num_is_sxnat0 "1"
      The status should equal 78
    End
  End
End
