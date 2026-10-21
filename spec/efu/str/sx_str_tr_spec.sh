Describe 'sx_str_tr -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_tr_spec.sh sx_str_tr

  It '正常動作'
    When run efu_run sx_str_tr res:cnt "a1b2c3" "abc" "XYZ"
    The status should be success
  End
  Parameters
    999999999999999999999999999999
    -999999999999999999999999999999
    -9223372036854775808
    +0
    -0
  End

  It '多倍長 limit と符号付きゼロを外部コマンドなしで処理すること'
    When run efu_run sx_str_tr res:cnt a1b2c3 abc XY "$1"
    The status should be success
  End
End
