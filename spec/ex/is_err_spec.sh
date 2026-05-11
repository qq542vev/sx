Describe 'sx_ex_is_err'
  Include ./sx.sh

  Describe '有効な10進数のエラーステータス'
    It '1 を検証すること'
      When call sx_ex_is_err 1
      The status should be success
    End

    It '255 を検証すること'
      When call sx_ex_is_err 255
      The status should be success
    End
  End

  Describe '無効なエラーステータス'
    It '0 を拒否すること'
      When call sx_ex_is_err 0
      The status should be failure
    End

    It '256 を拒否すること'
      When call sx_ex_is_err 256
      The status should be failure
    End

    It '-1 を拒否すること'
      When call sx_ex_is_err -1
      The status should be failure
    End

    It '先頭に 0 がある数値を拒否すること'
      When call sx_ex_is_err 01
      The status should be failure
    End
  End

  Describe '複数の引数'
    It '複数の有効なエラーステータスを検証すること'
      When call sx_ex_is_err 1 100 255
      The status should be success
    End

    It 'いずれかのステータスが無効（0を含む）な場合に拒否すること'
      When call sx_ex_is_err 1 0 255
      The status should be failure
    End
  End
End
