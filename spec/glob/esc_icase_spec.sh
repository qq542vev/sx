#!/bin/sh

Describe 'sx_glob_esc_icase'
  sxtest_load ./build/modules/sx_glob_esc_icase.sh

  Context '変換結果'
    Parameters
      01abCD6 '01[Aa][Bb][Cc][Dd]6'
      ABCDEFGHIJKLMNOPQRSTUVWXYZ '[Aa][Bb][Cc][Dd][Ee][Ff][Gg][Hh][Ii][Jj][Kk][Ll][Mm][Nn][Oo][Pp][Qq][Rr][Ss][Tt][Uu][Vv][Ww][Xx][Yy][Zz]'
      abcdefghijklmnopqrstuvwxyz '[Aa][Bb][Cc][Dd][Ee][Ff][Gg][Hh][Ii][Jj][Kk][Ll][Mm][Nn][Oo][Pp][Qq][Rr][Ss][Tt][Uu][Vv][Ww][Xx][Yy][Zz]'
      'a*b?[C]' '[Aa][*][Bb][?][[][Cc]]'
      '\A\z\' '[\\][Aa][\\][Zz][\\]'
      '\\' '[\\][\\]'
      '*?[' '[*][?][[]'
      '0123456789 ]!^-=:./' '0123456789 ]!^-=:./'
      '' ''
    End

    It '英字と特殊文字を変換し、その他の文字を保持する'
      When call sx_glob_esc_icase result "$1"
      The status should be success
      The variable result should equal "$2"
    End
  End

  It '文字列を省略すると既存の結果変数を空文字列にする'
    result=previous
    When call sx_glob_esc_icase result
    The status should be success
    The variable result should equal ''
  End

  It '入力と結果変数が同じでも変換できる'
    result='a*B'
    When call sx_glob_esc_icase result "$result"
    The status should be success
    The variable result should equal '[Aa][*][Bb]'
  End

  It '第3引数の追加文字をエスケープし、英字の大小を区別しない'
    input='a!^z]-' result=''
    When call sx_glob_esc_icase result "$input" '!^]-'
    The status should be success
    The variable result should equal '[Aa][[.!.]][[.^.]][Zz][]][-]'
    The variable input should match pattern "${result}"
  End

  It '引用符・ドル記号・改行をデータとして保持する'
    input="a'\"\$\`;
B"
    expected="[Aa]'\"\$\`;
[Bb]"
    When call sx_glob_esc_icase result "$input"
    The status should be success
    The variable result should equal "$expected"
  End

  Context '生成パターンでの照合'
    match_icase() {
      sx_glob_esc_icase result "$1"
      case "$2" in $result) return 0;; *) return 1;; esac
    }

    Parameters
      '01abCD6' '01ABcd6' 0
      '01abCD6' '01abcd6' 0
      '01abCD6' '01AbCd6' 0
      '01abCD6' '01abcd7' 1
      '01abCD6' 'x01abcd6' 1
      '01abCD6' '01abcd6x' 1
      'a*b?[C]' 'A*B?[c]' 0
      'a*b?[C]' 'AxByC' 1
      'a*b?[C]' 'a*b?C' 1
      'a\B' 'A\b' 0
      'a\B' 'ab' 1
      '[[:alpha:]]' '[[:ALPHA:]]' 0
      '[[:alpha:]]' 'A' 1
      '' '' 0
      '' 'a' 1
    End

    It '英字の大小だけを許容してリテラルとして照合する'
      When call match_icase "$1" "$2"
      The status should equal "$3"
    End
  End

  Context '結果変数名の検証'
    Parameters
      ''
      1result
      'result:count'
      'result;bad'
    End

    It '不正な結果変数名を拒否する'
      result=previous
      When call sx_glob_esc_icase "$1" abc
      The status should equal 64
      The variable result should equal previous
    End
  End

  It '結果変数名の省略を拒否する'
    When call sx_glob_esc_icase
    The status should equal 64
  End

  It '読み取り専用の結果変数を拒否する'
    readonly MYRO_GE_ICASE=previous
    When call sx_glob_esc_icase MYRO_GE_ICASE abc
    The status should equal 77
    The variable MYRO_GE_ICASE should equal previous
  End

  It '不正な設定値を拒否し、結果変数を保持する'
    SX_CFG_NUM_RANGE=invalid
    result=previous
    When call sx_glob_esc_icase result abc
    The status should equal 78
    The variable result should equal previous
  End

  It '未設定の設定値を拒否し、結果変数を保持する'
    unset SX_CFG_NUM_RANGE
    result=previous
    When call sx_glob_esc_icase result abc
    The status should equal 78
    The variable result should equal previous
  End

  It '検証省略時も同じ変換結果を返す'
    SX_CFG_SKIP_CHK=1
    When call sx_glob_esc_icase result 'a*B\'
    The status should be success
    The variable result should equal '[Aa][*][Bb][\\]'
  End
End

Describe '__sx_glob_esc_icase'
  sxtest_load ./build/modules/__sx_glob_esc_icase.sh

  It '内部モジュール単独でも英字と特殊文字を変換できる'
    When call __sx_glob_esc_icase result '01abCD6*?\['
    The status should be success
    The variable result should equal '01[Aa][Bb][Cc][Dd]6[*][?][\\][[]'
  End

  It '文字列を省略できる'
    When call __sx_glob_esc_icase result
    The status should be success
    The variable result should equal ''
  End
End
