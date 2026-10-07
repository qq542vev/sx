#!/bin/sh
eval "$(shellspec - -c) exit 1"

Describe 'sx_str_center'
  Include ./sx.sh

  # shellcheck disable=SC2329
  record_center_sizes() {
    center_repeats=
    center_slices=
    # 巨大な出力を割り当てず、生成回数と左右の抽出長を検証する。
    __sx_str_rep() {
      center_repeats="${center_repeats}${center_repeats:+ }${3}"
      eval "${1}="
    }
    __sx_str_substr() {
      center_slices="${center_slices}${center_slices:+ }${4}"
      eval "${1}="
    }
  }

  It '正の長さで中央寄せし、余りを右側に振ること (A 4 = -> =A==)'
    When call sx_str_center res "A" 4 "="
    The variable res should equal "=A=="
  End

  It '負の長さで中央寄せし、余りを左側に振ること (A -4 = -> ==A=)'
    When call sx_str_center res "A" -4 "="
    The variable res should equal "==A="
  End

  It '複数文字の埋め込み文字列を使用すること (A 5 xyz -> xyAxy)'
    # 5文字、Aが1文字、パディング4文字。左2、右2。
    # xyz -> xy (左), xyz -> xy (右)
    When call sx_str_center res "A" 5 "xyz"
    The variable res should equal "xyAxy"
  End

  It 'デフォルトでスペースを使用すること (A 3 -> " A ")'
    When call sx_str_center res "A" 3
    The variable res should equal " A "
  End

  It '既に指定された長さ以上の場合はそのまま返すこと'
    When call sx_str_center res "ABCDE" 3 "="
    The variable res should equal "ABCDE"
  End

  It '長さ 0 の場合はそのまま返すこと'
    When call sx_str_center res "ABC" 0 "="
    The variable res should equal "ABC"
  End

  It '結果変数が読み取り専用の場合は NOPERM を返すこと'
    readonly ro_var="init"
    When call sx_str_center ro_var "A" 4
    The status should equal 77
  End

  It '長さが数値でない場合は USAGE を返すこと'
    When call sx_str_center res "A" "invalid"
    The status should equal 64
  End

  It '埋め込み文字列が空の場合は何もしないこと (A 4 "" -> A)'
    When call sx_str_center res "A" 4 ""
    The variable res should equal "A"
    The status should equal 0
  End

  It '非常に大きな幅（1000）で中央寄せできること'
    When call sx_str_center res "x" 1000
    The length of variable res should equal 1000
  End

  It '埋め込み文字にタブを使用できること'
    tab=$(printf '\t')
    When call sx_str_center res "A" 5 "${tab}"
    The variable res should equal "${tab}${tab}A${tab}${tab}"
  End

  It '負の大きな幅で中央寄せできること'
    When call sx_str_center res "A" -1000 "="
    The length of variable res should equal 1000
  End

  It '埋め込み文字列が空で幅不足の場合、元の文字列を返すこと'
    When call sx_str_center res "ABC" 5 ""
    The variable res should equal "ABC"
  End

  It '右埋め文字列を指定できること (A 5 . = -> ..A==)'
    # needed=4, lpad=2, rpad=2
    When call sx_str_center res "A" 5 "." "="
    The variable res should equal "..A=="
  End

  It '負の幅で右埋め文字列を指定できること (A -5 . = -> ..A==)'
    # needed=4, lpad=2, rpad=2（偶数なので左右均等）
    When call sx_str_center res "A" -5 "." "="
    The variable res should equal "..A=="
  End

  It '左埋め文字列のみ指定で従来動作（後方互換）(A 4 = -> =A==)'
    When call sx_str_center res "A" 4 "="
    The variable res should equal "=A=="
  End

  It '左埋め文字列が空で右埋め文字列のみの場合 (A 5 "" = -> A==)'
    # 左が空のため左パッド無し、右のみ"="×2
    When call sx_str_center res "A" 5 "" "="
    The variable res should equal "A=="
  End

  It '右埋め文字列が空で左埋め文字列のみの場合 (A 5 . "" -> ..A)'
    # 右が空のため右パッド無し、左のみ"."×2
    When call sx_str_center res "A" 5 "." ""
    The variable res should equal "..A"
  End

  It '複数文字の左右別埋め文字列を使用すること (A 6 ab xy -> abAxyx)'
    When call sx_str_center res "A" 6 "ab" "xy"
    The variable res should equal "abAxyx"
  End

  It '両方とも空の埋め文字列の場合は元の文字列を返すこと (A 5 "" "" -> A)'
    When call sx_str_center res "A" 5 "" ""
    The variable res should equal "A"
  End

  Context '符号と幅の境界'
    Parameters
      '+4' 'aAxy'
      '-4' 'abAx'
      '2' 'Ax'
      '-2' 'aA'
      '1' 'A'
      '-1' 'A'
      '0' 'A'
      '+0' 'A'
      '-0' 'A'
    End

    It "幅 $1 で左右に正しく配分すること"
      When call sx_str_center res 'A' "$1" 'ab' 'xy'
      The status should be success
      The variable res should equal "$2"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '幅を省略した場合は元文字列を返すこと'
    When call sx_str_center res 'ABC'
    The status should be success
    The variable res should equal 'ABC'
  End

  It '空の元文字列も左右別の文字列で埋められること'
    When call sx_str_center res '' -5 'ab' 'xy'
    The status should be success
    The variable res should equal 'abaxy'
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
      When call sx_str_center res 'A' "$1" '' ''
      The status should equal 64
      The variable res should equal 'before'
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '算術域を超える幅と空の埋め文字列'
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
      When call sx_str_center res 'ABC' "$1" ''
      The status should be success
      The variable res should equal 'ABC'
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '巨大な幅の配分と繰り返し回数'
    Before 'sx_cfg_set NUM_RANGE=32'
    Before 'record_center_sizes'

    Parameters
      # shellcheck disable=SC2286
      '' '2147483647' '1073741823 1073741824' '536870912 357913942'
      # shellcheck disable=SC2286
      '' '-2147483647' '1073741824 1073741823' '536870912 357913941'
      'A' '+2147483648' '1073741823 1073741824' '536870912 357913942'
      'A' '-2147483648' '1073741824 1073741823' '536870912 357913941'
      'A' '-9223372036854775808' '4611686018427387904 4611686018427387903' '2305843009213693952 1537228672809129301'
      'A' '1000000000000000000000000000000' '499999999999999999999999999999 500000000000000000000000000000' '250000000000000000000000000000 166666666666666666666666666667'
      'A' '-1000000000000000000000000000000' '500000000000000000000000000000 499999999999999999999999999999' '250000000000000000000000000000 166666666666666666666666666667'
      'A' '1000000000000000000000000000001' '500000000000000000000000000000 500000000000000000000000000000' '250000000000000000000000000000 166666666666666666666666666667'
    End

    It "幅 $2 の配分と繰り返し回数が桁あふれしないこと"
      When call sx_str_center res "$1" "$2" 'ab' 'xyz'
      The status should be success
      The variable center_slices should equal "$3"
      The variable center_repeats should equal "$4"
      The variable res should equal "$1"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '生成処理の境界'
    Before 'record_center_sizes'

    It '64bit最大値でも不足長に1を加算せず配分できること'
      Skip if '64bit算術を使用できないため' arith_lt64
      sx_cfg_set NUM_RANGE=64
      When call sx_str_center res '' 9223372036854775807 'ab' 'xyz'
      The status should be success
      The variable center_slices should equal '4611686018427387903 4611686018427387904'
      The variable center_repeats should equal '2305843009213693952 1537228672809129302'
      The stderr should equal ''
    End

    It '左右の埋め文字列が同じなら長い側に合わせて一度だけ生成すること'
      sx_cfg_set NUM_RANGE=32
      When call sx_str_center res 'A' -2147483648 'xyz'
      The status should be success
      The variable center_slices should equal '1073741824 1073741823'
      The variable center_repeats should equal '357913942'
      The stderr should equal ''
    End
  End

  Context '文字列長を多倍長で処理する経路'
    Before 'force_center_multiprecision'

    # shellcheck disable=SC2329
    force_center_multiprecision() {
      # 4値の範囲検査だけを範囲外とし、下位演算の小さな値は範囲内とする。
      __sx_num_is_int_fit_dec() {
        case "${#}" in 5) return 1;; esac
        return 0
      }
    }

    Parameters
      'A' '6' 'ab' 'xyz' 'abAxyz'
      'A' '-6' 'ab' 'xyz' 'abaAxy'
      'A' '6' 'xyz' 'xyz' 'xyAxyz'
      'A' '-6' 'xyz' 'xyz' 'xyzAxy'
      'A' '4' '' 'xyz' 'Axy'
      'A' '-4' 'abc' '' 'abA'
      'A' '2' 'abc' 'xyz' 'Ax'
      'A' '-2' 'abc' 'xyz' 'aA'
      'ABCDE' '3' '=' '=' 'ABCDE'
      'ABCDE' '-5' '=' '=' 'ABCDE'
      # shellcheck disable=SC2286
      '' '-5' 'ab' 'xy' 'abaxy'
    End

    It '文字列長と左右の埋め文字列長を多倍長で処理できること'
      When call sx_str_center res "$1" "$2" "$3" "$4"
      The status should be success
      The variable res should equal "$5"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '検証を省略しても巨大な幅と空の埋め文字列を処理できること'
    sx_cfg_set SKIP_CHK=1
    When call sx_str_center res 'ABC' -1000000000000000000000000000000 '' ''
    The status should be success
    The variable res should equal 'ABC'
    The stderr should equal ''
  End
End
