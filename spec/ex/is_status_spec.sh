#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_ex_is_status'
  Include ./sx.sh

  Describe '有効な10進数のステータス'
    It '0 を検証すること'
      When call sx_ex_is_status 0
      The status should be success
    End

    It '1 を検証すること'
      When call sx_ex_is_status 1
      The status should be success
    End

    It '255 を検証すること'
      When call sx_ex_is_status 255
      The status should be success
    End
  End

  Describe '無効なステータス'
    It '256 を拒否すること'
      When call sx_ex_is_status 256
      The status should be failure
    End

    It '-1 を拒否すること'
      When call sx_ex_is_status -1
      The status should be failure
    End

    It '英字を拒否すること'
      When call sx_ex_is_status abc
      The status should be failure
    End

    It '先頭に 0 がある数値を拒否すること（0そのものを除く）'
      When call sx_ex_is_status 01
      The status should be failure
    End

    It '16進数を拒否すること'
      When call sx_ex_is_status 0x10
      The status should be failure
    End
  End

  Describe '複数の引数'
    It '複数の有効なステータスを検証すること'
      When call sx_ex_is_status 0 100 255
      The status should be success
    End

    It 'いずれかのステータスが無効な場合に拒否すること'
      When call sx_ex_is_status 0 256 255
      The status should be failure
    End
  End
End
