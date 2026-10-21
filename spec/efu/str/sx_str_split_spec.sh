Describe 'sx_str_split -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_split_spec.sh sx_cfg_set sx_str_split

  Context '多倍長の回数と直接バインド'
    Parameters
      0 abc '' 999999999999999999999999 0
      1 abc '' 999999999999999999999999 2
      0 abc '' -9223372036854775808 0
      1 abc '' -999999999999999999999999 2
      0 abc '' -2 2
      1 abc '**' '' 3
      0 'a:b:c' : 999999999999999999999999 2
      1 a1b2c '[0-9]' -999999999999999999999999 3
      0 abc '' -0 2
    End

    It '検査の有無によらず-efu下で成功すること'
      sx_cfg_set "SKIP_CHK=$1"
      When run efu_run sx_str_split 'a:b:rem' "$2" "$3" "$4" "$5"
      The status should be success
    End
  End

  It '正常動作'

    When run efu_run sx_str_split "a:b:rem" "v1:v2:v3:v4" ":"
    The status should be success
  End
End
