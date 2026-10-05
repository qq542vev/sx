Describe 'sx_str_rev -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_str_rev res "hello"
    The status should be success
  End

  It '文字列を省略しても正常に終了すること'
    When run efu_run sx_str_rev res
    The status should be success
    The stderr should equal ''
  End

  It '空のチャンクサイズでも正常に終了すること'
    When run efu_run sx_str_rev res "abc" ""
    The status should be success
    The stderr should equal ''
  End

  It '+ 付きのチャンクサイズでも正常に終了すること'
    When run efu_run sx_str_rev res "abcdefgh" +3
    The status should be success
    The stderr should equal ''
  End

  It 'メタ文字を含む負方向のチャンク反転でも正常に終了すること'
    When run efu_run sx_str_rev res "a*b?c[d]" -6
    The status should be success
    The stderr should equal ''
  End

  Context '数値範囲を超える10進表記のチャンクサイズ'
    Before 'sx_cfg_set NUM_RANGE=32'

    Parameters
      '9223372036854775809'
      '+9223372036854775809'
      '-9223372036854775809'
    End

    It "サイズ $1 でも正常に終了すること"
      When run efu_run sx_str_rev res "abc" "$1"
      The status should be success
      The stderr should equal ''
    End
  End

  Context '8進・16進表記のチャンクサイズ'
    Parameters
      '010'
      '0xb'
    End

    It "サイズ $1 を64で拒否すること"
      When run efu_run sx_str_rev res "abc" "$1"
      The status should equal 64
      The stderr should equal ''
    End
  End
End
