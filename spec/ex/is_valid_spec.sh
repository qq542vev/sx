#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_ex_is_valid'
  Include ./sx.sh

  Describe '有効な数値ステータス'
    It '0 を検証すること'
      When call sx_ex_is_valid 0
      The status should be success
    End

    It '255 を検証すること'
      When call sx_ex_is_valid 255
      The status should be success
    End
  End

  Describe '有効な名前付きステータス'
    It 'OK を検証すること'
      When call sx_ex_is_valid OK
      The status should be success
    End

    It 'USAGE を検証すること'
      When call sx_ex_is_valid USAGE
      The status should be success
    End

    It 'CONFIG を検証すること'
      When call sx_ex_is_valid CONFIG
      The status should be success
    End
  End

  Describe '混合引数'
    It '数値と名前が混在していても検証できること'
      When call sx_ex_is_valid 0 USAGE 255 CONFIG
      The status should be success
    End
  End

  Describe '無効なステータス'
    It '範囲外の数値 (256) を拒否すること'
      When call sx_ex_is_valid 256
      The status should be failure
    End

    It '負の数値 (-1) を拒否すること'
      When call sx_ex_is_valid -1
      The status should be failure
    End

    It '未知の名前 (INVALID) を拒否すること'
      When call sx_ex_is_valid INVALID
      The status should be failure
    End

    It 'プレフィックス付きの名前 (SX_EX_OK) を拒否すること'
      When call sx_ex_is_valid SX_EX_OK
      The status should be failure
    End

    It '一つでも無効な値があれば失敗すること'
      When call sx_ex_is_valid OK 256 USAGE
      The status should be failure
    End
  End

  Describe 'エッジケース'
    It '引数がない場合は成功すること'
      When call sx_ex_is_valid
      The status should be success
    End

    It '空文字列を拒否すること'
      When call sx_ex_is_valid ""
      The status should be failure
    End
  End
End
