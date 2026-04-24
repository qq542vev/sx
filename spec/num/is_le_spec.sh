Describe 'sx_num_is_le'
  Include ./sx.sh
  It '数値が非減少順（昇順または等しい）である場合に成功を返すこと'
    When call sx_num_is_le 1 2 2 3
    The status should be success
  End

  It '数値が非減少順でない場合に失敗を返すこと'
    When call sx_num_is_le 1 3 2
    The status should be failure
  End

  It '非数値の入力に対して失敗を返すこと'
    When call sx_num_is_le 1 "a"
    The status should be failure
  End
End
