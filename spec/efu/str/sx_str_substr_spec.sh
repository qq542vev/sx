Describe 'sx_str_substr -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_str_substr res "abcdef" 2 3
    The status should be success
  End

  It '文字列を省略しても正常に終了すること'
    When run efu_run sx_str_substr res
    The status should be success
    The stderr should equal ''
  End

  It '長さを省略しても正常に終了すること'
    When run efu_run sx_str_substr res "abcdef" +2
    The status should be success
    The stderr should equal ''
  End

  It '負のオフセットと負の長さを処理できること'
    When run efu_run sx_str_substr res "a*b?c[d]" -6 -1
    The status should be success
    The stderr should equal ''
  End

  Context '巨大な引数'
    Before 'sx_cfg_set NUM_RANGE=32'

    Parameters
      '+9223372036854775808' '+9223372036854775808'
      '-9223372036854775808' '+9223372036854775808'
      '-9223372036854775808' '-9223372036854775808'
    End

    It "オフセット $1、長さ $2 を処理できること"
      When run efu_run sx_str_substr res "abcdef" "$1" "$2"
      The status should be success
      The stderr should equal ''
    End
  End

  Context '不正な数値引数'
    Parameters
      '010' '2'
      '2' '0xb'
      '' '2'
      '2' ''
    End

    It '64で拒否すること'
      When run efu_run sx_str_substr res "abcdef" "$1" "$2"
      The status should equal 64
      The stderr should equal ''
    End
  End

  Context '先頭を越える負のオフセット'
    Parameters
      '2'
      '3'
      '4'
      '-1'
    End

    It '範囲外を含め警告なしで成功すること'
      When run efu_run sx_str_substr res 'abcde' -8 "$1"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
