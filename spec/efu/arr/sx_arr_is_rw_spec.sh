Describe 'sx_arr_is_rw -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    sx_arr_gen arr a b c

    When run efu_run sx_arr_is_rw arr
    The status should be success
  End

  It '読み取り専用要素を検出できること'
    arr_len=1 arr_0=a
    readonly arr_0

    When run efu_run sx_arr_is_rw arr
    The status should be failure
  End
End
