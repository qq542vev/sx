#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_num_safe'
  Include ./sx.sh

  Context '10進整数'
    It '0, 123, -456 を検証すること'
      When call sx_num_is_num_safe "0" "123" "-456"
      The status should be success
    End
  End

  Context '16進整数'
    It '0x123, -0xABC を検証すること'
      When call sx_num_is_num_safe "0x123" "-0xABC"
      The status should be success
    End

    It '無効な16進数を拒否すること'
      When call sx_num_is_num_safe "0xG"
      The status should be failure
    End
  End

  Context '8進整数'
    It '0123, -077 を検証すること'
      When call sx_num_is_num_safe "0123" "-077"
      The status should be success
    End

    It '無効な8進数を拒否すること'
      When call sx_num_is_num_safe "08"
      The status should be failure
    End
  End

  Context '浮動小数点数'
    It '0.5, 1.23, -0.01, 1e10, 1.2e-3 を検証すること'
      When call sx_num_is_num_safe "0.5" "1.23" "-0.01" "1e10" "1.2e-3"
      The status should be success
    End

    It '無効な浮動小数点形式を拒否すること'
      When call sx_num_is_num_safe "0.1.2" "1.2a" "01.2"
      The status should be failure
    End
  End

  Context '設定エラー'
    Before 'SX_CFG_NUM_RANGE=abc'
    It '8進数などを渡した時に 78 が返ること'
      When call sx_num_is_num_safe "0123"
      The status should equal 78
    End
  End

  Context '複合引数'
    It 'すべての型が混在していても検証できること'
      When call sx_num_is_num_safe "123" "0xABC" "077" "0.5" "1e-2"
      The status should be success
    End

    It '一つでも無効な値があれば失敗すること'
      When call sx_num_is_num_safe "123" "abc" "0.5"
      The status should be failure
    End
  End
End
