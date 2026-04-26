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

  It '非数値の入力(後方)が含まれる場合に失敗を返すこと'
    When call sx_num_is_le 1 "a"
    The status should be failure
  End

  It '非数値の入力(前方)が含まれる場合に失敗を返すこと'
    When call sx_num_is_le "a" 1
    The status should be failure
  End

  It '1つの引数に対して成功を返すこと'
    When call sx_num_is_le 1
    The status should be success
  End

  It '引数がない場合に成功を返すこと'
    When call sx_num_is_le
    The status should be success
  End
End
