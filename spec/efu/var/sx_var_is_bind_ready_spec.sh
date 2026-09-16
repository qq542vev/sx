Describe 'sx_var_is_bind_ready -efu 環境検証'
  Include ./sx.sh

  It '準備済みの場合の正常動作'
    bir_efu_ok_case() {
      sx_var_bind_init "bir_e1:bir_e2"
      sx_var_is_bind_ready "bir_e1:bir_e2"
    }

    When run efu_run bir_efu_ok_case
    The status should be success
  End

  It '未準備の場合の失敗動作'
    bir_efu_ng_case() {
      unset bir_e3 bir_e4
      sx_var_is_bind_ready "bir_e3:bir_e4"
    }

    When run efu_run bir_efu_ng_case
    The status should equal 1
  End

  It '不正形式の場合の失敗動作'
    bir_efu_bad_case() {
      sx_var_is_bind_ready "bad-name"
    }

    When run efu_run bir_efu_bad_case
    The status should equal 64
  End
End
