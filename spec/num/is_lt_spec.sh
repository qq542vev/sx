Describe 'sx_num_is_lt'
  Include ./sx.sh
  It '数値が厳密に増加順（昇順）である場合に成功を返すこと'
    When call sx_num_is_lt 1 2 3
    The status should be success
  End

  It '数値が厳密に増加順でない場合に失敗を返すこと'
    When call sx_num_is_lt 1 2 2 3
    The status should be failure
  End

  It '非数値の入力が含まれる場合に失敗を返すこと'
    When call sx_num_is_lt 1 "a"
    The status should be failure
  End

  It '1つの引数に対して成功を返すこと'
    When call sx_num_is_lt 1
    The status should be success
  End

  It '引数がない場合に成功を返すこと'
    When call sx_num_is_lt
    The status should be success
  End
End
