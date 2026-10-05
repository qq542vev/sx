Describe 'sx_str_rep -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_str_rep res "a" 3
    The status should be success
  End

  It '回数を省略しても正常に終了すること'
    When run efu_run sx_str_rep res "z"
    The status should be success
    The stderr should equal ''
  End

  It '文字列を省略しても正常に終了すること'
    When run efu_run sx_str_rep res
    The status should be success
    The stderr should equal ''
  End

  It '空の回数でも正常に終了すること'
    When run efu_run sx_str_rep res "z" ""
    The status should be success
    The stderr should equal ''
  End

  It '16進表記の回数を64で拒否すること'
    When run efu_run sx_str_rep res "x" 0xb
    The status should equal 64
    The stderr should equal ''
  End

  It '数値範囲を超える10進表記の回数でも正常に終了すること'
    sx_cfg_set NUM_RANGE=32
    When run efu_run sx_str_rep res "" 9223372036854775809
    The status should be success
    The stderr should equal ''
  End
End
