Describe 'sx_str_center -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_str_center res "A" 4 ""
    The status should be success
  End

  Context '符号と左右の埋め文字列'
    Parameters
      '+6' 'ab' 'xy'
      '-6' 'ab' 'xy'
      '2' '' 'xy'
      '-2' 'ab' ''
      '+0' 'ab' 'xy'
      '-0' 'ab' 'xy'
    End

    It '正常に終了すること'
      When run efu_run sx_str_center res 'A' "$1" "$2" "$3"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '幅を省略しても正常に終了すること'
    When run efu_run sx_str_center res 'ABC'
    The status should be success
    The stderr should equal ''
  End

  Context '算術域を超える幅'
    Before 'sx_cfg_set NUM_RANGE=32'

    Parameters
      '+2147483648'
      '-2147483648'
      '+9223372036854775808'
      '-9223372036854775808'
      '-1000000000000000000000000000000'
    End

    It '空の埋め文字列で正常に終了すること'
      When run efu_run sx_str_center res 'ABC' "$1" '' ''
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End

    It '巨大な出力を生成せず多倍長計算を完了できること'
      __sx_str_rep() { eval "${1}="; }
      When run efu_run sx_str_center res 'A' "$1" 'ab' 'xyz'
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '不正な幅'
    Parameters
      # ShellSpec の入力データとして空文字列を指定する。
      # shellcheck disable=SC2286
      ''
      '010'
      '0x3'
      '1.5'
      '+'
    End

    It '64で拒否すること'
      When run efu_run sx_str_center res 'A' "$1" '' ''
      The status should equal 64
      The stderr should equal ''
    End
  End
End
