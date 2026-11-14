Describe 'sx_str_incl -efu 環境検証'
  sxtest_load ./build/modules/sx_str_incl.sh

  It '正常動作'
    When run efu_run sx_str_incl "bc" "abc"
    The status should equal 1
  End

  It '正常動作等長'
    When run efu_run sx_str_incl "abc" "abc"
    The status should equal 2
  End

  It '正常動作含む'
    When run efu_run sx_str_incl "abc" "bc"
    The status should equal 3
  End

  It '正常動作互いに素'
    When run efu_run sx_str_incl "abc" "def"
    The status should equal 4
  End
End
