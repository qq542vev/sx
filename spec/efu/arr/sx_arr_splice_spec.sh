Describe 'sx_arr_splice -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    sx_arr_gen myarr a b c d

    When run efu_run sx_arr_splice myarr 1 2 X Y
    The status should be success
  End

  It '負数でも -efu 下で動作すること'
    sx_arr_gen myarr a b c d

    When run efu_run sx_arr_splice myarr -1 1 X
    The status should be success
  End

  It 'del が負でも -efu 下で動作すること'
    sx_arr_gen myarr a b c d

    When run efu_run sx_arr_splice myarr 1 -1
    The status should be success
  End

  It '負数の複合でも -efu 下で動作すること'
    sx_arr_gen myarr a b c d

    When run efu_run sx_arr_splice myarr -2 -1 X
    The status should be success
  End

  It '不正形式でも -efu 下で EX_USAGE を返すこと'
    sx_arr_gen myarr a b

    When run efu_run sx_arr_splice myarr 01 1 X
    The status should equal 64
  End
End
