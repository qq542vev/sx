Describe 'sx_str_is_sword -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_sword.sh

  It '英字とアンダースコアを受理すること'
    When run efu_run sx_str_is_sword 'abc' '_ABC' 'a_b_'
    The status should be success
  End

  It '数字が含まれる場合は1を返すこと'
    When run efu_run sx_str_is_sword 'abc' 'def1'
    The status should equal 1
  End

  It '空文字列の場合は1を返すこと'
    When run efu_run sx_str_is_sword ''
    The status should equal 1
  End

  It '引数なしの場合は成功を返すこと'
    When run efu_run sx_str_is_sword
    The status should be success
  End
End
