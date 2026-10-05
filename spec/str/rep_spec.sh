#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_rep'
  Include ./sx.sh
  It '指定された回数だけ文字列を繰り返すこと'
    When call sx_str_rep res "a" 3
    The variable res should equal "aaa"
  End

  It '0回繰り返した場合に空文字列を返すこと'
    When call sx_str_rep res "abc" 0
    The variable res should equal ""
  End

  It '1回繰り返した場合に同じ文字列を返すこと'
    When call sx_str_rep res "abc" 1
    The variable res should equal "abc"
  End

  It '2のべき乗ではない回数を処理できること'
    When call sx_str_rep res "x" 7
    The variable res should equal "xxxxxxx"
  End

  It '正の偶数回だけ文字列を繰り返すこと'
    When call sx_str_rep res "ab" 4
    The status should be success
    The variable res should equal "abababab"
  End

  It '複数桁の10進表記の回数を処理できること'
    When call sx_str_rep res "ab" 13
    The variable res should equal "ababababababababababababab"
  End

  It '空文字列を処理できること'
    When call sx_str_rep res "" 10
    The variable res should equal ""
  End

  It '回数が省略された場合にデフォルトの1回になること'
    When call sx_str_rep res "z"
    The status should be success
    The variable res should equal "z"
  End

  It '文字列が省略された場合にデフォルトの空文字列になること'
    When call sx_str_rep res
    The status should be success
    The variable res should equal ""
  End

  It '回数が空の場合にデフォルトの1回になること'
    When call sx_str_rep res "z" ""
    The status should be success
    The variable res should equal "z"
  End

  It '呼び出し側で16進数を10進表記に変換すれば受理すること'
    When call sx_str_rep res "x" "$((0xb))"
    The status should be success
    The variable res should equal "xxxxxxxxxxx"
  End

  Context '10進表記以外または不正な回数'
    Parameters
      '010'
      '0xb'
      '0XB'
      '00'
      '08'
      '+3'
      '-0'
      '1.5'
      '1e1'
      '2+1'
      ' 3'
      # ShellSpec の入力データであり、末尾空白を含むコマンド名ではない。
      # shellcheck disable=SC2288
      '3 '
    End

    It "回数 <$1> を64で拒否して結果変数を変更しないこと"
      res=before
      When call sx_str_rep res "a" "$1"
      The status should equal 64
      The variable res should equal "before"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '数値範囲を超える10進表記の回数'
    Before 'sx_cfg_set NUM_RANGE=32'

    Parameters
      '2147483648'
      '9223372036854775809'
      '1000000000000000000000000000000'
    End

    It "回数 $1 を受理して空文字列を繰り返せること"
      # 巨大な出力を生成せず、回数の受理と多倍長処理の終了を検証する。
      When call sx_str_rep res "" "$1"
      The status should be success
      The variable res should equal ""
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '負の回数に対してEX_USAGE (64)を返すこと'
    When call sx_str_rep res "a" -1
    The status should equal 64
  End

  It '整数ではない回数に対してEX_USAGE (64)を返すこと'
    When call sx_str_rep res "a" "abc"
    The status should equal 64
  End

  It '読み取り専用の変数に対してEX_NOPERM (77)を返すこと'
    readonly ro_res_rep="fixed"
    When call sx_str_rep ro_res_rep "a" 3
    The status should equal 77
  End
End
