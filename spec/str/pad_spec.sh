#!/bin/sh
eval "$(shellspec - -c) exit 1"

Describe 'sx_str_pad'
  Include ./sx.sh

  It '正の長さで左側に埋めること (A 3 = -> ==A)'
    When call sx_str_pad res "A" 3 "="
    The variable res should equal "==A"
  End

  It '正の長さで左側に埋めること (A 3 xyz -> xyA)'
    When call sx_str_pad res "A" 3 "xyz"
    The variable res should equal "xyA"
  End

  It '負の長さで右側に埋めること (A -3 xyz -> Axy)'
    When call sx_str_pad res "A" -3 "xyz"
    The variable res should equal "Axy"
  End

  It 'デフォルトでスペースを使用すること (A 3 -> "  A")'
    When call sx_str_pad res "A" 3
    The variable res should equal "  A"
  End

  It '既に指定された長さ以上の場合はそのまま返すこと'
    When call sx_str_pad res "ABCDE" 3 "="
    The variable res should equal "ABCDE"
  End

  It '長さ 0 の場合はそのまま返すこと'
    When call sx_str_pad res "ABC" 0 "="
    The variable res should equal "ABC"
  End
  
  It '埋め込み文字列が複数文字で繰り返しが必要な場合'
    When call sx_str_pad res "A" 5 "xyz"
    The variable res should equal "xyzxA"
  End
  
  It '結果変数が読み取り専用の場合は NOPERM を返すこと'
    readonly ro_var="init"
    When call sx_str_pad ro_var "A" 3
    The status should equal 77
  End

  It '長さが数値でない場合は USAGE を返すこと'
    When call sx_str_pad res "A" "invalid"
    The status should equal 64
  End

  It '埋め込み文字列が空の場合は何もしないこと (A 3 "" -> A)'
    When call sx_str_pad res "A" 3 ""
    The variable res should equal "A"
    The status should equal 0
  End

  It '非常に大きな幅（1000）でパディングできること'
    When call sx_str_pad res "x" 1000
    The length of variable res should equal 1000
  End

  It 'パディング文字にタブを使用できること'
    tab=$(printf '\t')
    When call sx_str_pad res "A" 3 "${tab}"
    The variable res should equal "${tab}${tab}A"
  End

  It '負の大きな幅で右側にパディングできること'
    When call sx_str_pad res "A" -1000 "${SX_STR_LF}"
    The length of variable res should equal 1000
  End

  It 'パディング文字が空文字で幅不足の場合、元の文字列を返すこと'
    When call sx_str_pad res "ABC" 5 ""
    The variable res should equal "ABC"
  End

  Context '符号付き10進表記と境界'
    Parameters
      '+5' 'xyzxA'
      '-5' 'Axyzx'
      '0' 'A'
      '+0' 'A'
      '-0' 'A'
      '1' 'A'
      '-1' 'A'
    End

    It "幅 $1 を処理できること"
      When call sx_str_pad res 'A' "$1" 'xyz'
      The status should be success
      The variable res should equal "$2"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '長さを省略した場合は元文字列を返すこと'
    When call sx_str_pad res 'ABC'
    The status should be success
    The variable res should equal 'ABC'
  End

  It '空の元文字列を繰り返しの境界で埋められること'
    When call sx_str_pad res '' 6 'xyz'
    The status should be success
    The variable res should equal 'xyzxyz'
  End

  It 'パターン文字を含む埋め込み文字列をそのまま使用すること'
    When call sx_str_pad res 'A' -8 '*?[x]'
    The status should be success
    The variable res should equal 'A*?[x]*?'
  End

  Context '不正な幅'
    Parameters
      # ShellSpec の入力データとして空文字列を指定する。
      # shellcheck disable=SC2286
      ''
      '00'
      '010'
      '08'
      '+010'
      '-010'
      '0x3'
      '-0X3'
      '1.5'
      '1e2'
      '2+1'
      ' 3'
      '+'
      '-'
    End

    It "幅 <$1> を64で拒否して結果変数を変更しないこと"
      res=before
      When call sx_str_pad res 'A' "$1" ''
      The status should equal 64
      The variable res should equal 'before'
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '算術域を超える幅と空の埋め込み文字列'
    Before 'sx_cfg_set NUM_RANGE=32'

    Parameters
      '2147483648'
      '+2147483648'
      '-2147483648'
      '9223372036854775808'
      '-9223372036854775808'
      '+1000000000000000000000000000000'
      '-1000000000000000000000000000000'
    End

    It "幅 $1 を受理して元文字列を返すこと"
      When call sx_str_pad res 'ABC' "$1" ''
      The status should be success
      The variable res should equal 'ABC'
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '多倍長の不足長と繰り返し回数'
    Before 'sx_cfg_set NUM_RANGE=32'
    Before 'guard_pad_repeat'

    # shellcheck disable=SC2329
    guard_pad_repeat() {
      pad_repeat_count=
      # 巨大な出力の生成を置き換え、減算と切り上げ除算の結果を検証する。
      __sx_str_rep() {
        pad_repeat_count="${3}"
        eval "${1}="
      }
    }

    Parameters
      '2147483648' '715827883'
      '-2147483648' '715827883'
      '+9223372036854775808' '3074457345618258603'
      '-9223372036854775808' '3074457345618258603'
      '1000000000000000000000000000000' '333333333333333333333333333333'
      '-1000000000000000000000000000001' '333333333333333333333333333334'
    End

    It "幅 $1 に必要な繰り返し回数を桁あふれせず求めること"
      When call sx_str_pad res 'A' "$1" 'xyz'
      The status should be success
      The variable pad_repeat_count should equal "$2"
      The variable res should equal 'A'
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '文字列長を多倍長で処理する経路'
    Before 'force_pad_multiprecision'

    # shellcheck disable=SC2329
    force_pad_multiprecision() {
      # 巨大な実文字列を割り当てず、範囲外判定後の文字列処理を検証する。
      # 3値を検査する経路だけ範囲外とし、下位演算の小さな値は範囲内とする。
      __sx_num_is_int_fit_dec() {
        case "${#}" in 4) return 1;; esac
        return 0
      }
    }

    Parameters
      'A' '5' 'xyz' 'xyzxA'
      'A' '-5' 'xyz' 'Axyzx'
      # shellcheck disable=SC2286
      '' '6' 'xyz' 'xyzxyz'
      'ABCDE' '3' '=' 'ABCDE'
      'ABCDE' '-5' '=' 'ABCDE'
      'A' '0' 'xyz' 'A'
      'A' '3' 'xyzxyzxyz' 'xyA'
    End

    It '文字列長と埋め込み文字列長を多倍長で処理して正しく埋めること'
      When call sx_str_pad res "$1" "$2" "$3"
      The status should be success
      The variable res should equal "$4"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '検証を省略しても巨大な幅と空の埋め込み文字列を処理できること'
    sx_cfg_set SKIP_CHK=1
    When call sx_str_pad res 'ABC' -1000000000000000000000000000000 ''
    The status should be success
    The variable res should equal 'ABC'
    The stderr should equal ''
  End
End
