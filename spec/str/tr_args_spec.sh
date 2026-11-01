#!/bin/sh
# shellcheck shell=sh disable=SC2154
# 結果変数は参照渡しで設定される。

Describe 'sx_str_tr_args'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_str_tr_args.sh

  multibyte_is_unavailable() {
    set -- あ
    case "${#1}" in 1) return 1;; esac
    return 0
  }

  It '置換先を複数文字と空文字で指定できること'
    When call sx_str_tr_args res:cnt abcab abc AA '' xyz
    The status should be success
    The variable res should equal AAxyzAA
    The variable cnt should equal "'5'"
    The stdout should equal ''
    The stderr should equal ''
  End

  It '区切りなしでは数値も置換先になること'
    When call sx_str_tr_args res:cnt abc abc 1 2 3
    The status should be success
    The variable res should equal 123
    The variable cnt should equal "'3'"
  End

  It '区切りなしでは不正な整数に見える値も置換先になること'
    When call sx_str_tr_args res:cnt abc abc 01 --1 '+'
    The status should be success
    The variable res should equal '01--1+'
    The variable cnt should equal "'3'"
  End

  It '区切りだけを指定して全置換できること'
    When call sx_str_tr_args res:cnt a1b2c3 abc ::: AA BB CC
    The status should be success
    The variable res should equal AA1BB2CC3
    The variable cnt should equal "'3'"
  End

  Context 'limitの方向と回数'
    Parameters
      '' AA1BB2CC3 "'3'"
      0 a1b2c3 "'0'"
      +0 a1b2c3 "'0'"
      -0 a1b2c3 "'0'"
      1 AA1b2c3 "'1'"
      +2 AA1BB2c3 "'2'"
      -1 a1b2CC3 "'1'"
      -2 a1BB2CC3 "'2'"
      9 AA1BB2CC3 "'3'"
      -9 AA1BB2CC3 "'3'"
      999999999999999999999999999999 AA1BB2CC3 "'3'"
      -999999999999999999999999999999 AA1BB2CC3 "'3'"
    End

    It '元の文字への一致回数で制限すること'
      When call sx_str_tr_args res:cnt a1b2c3 abc "$1" ::: AA BB CC
      The status should be success
      The variable res should equal "$2"
      The variable cnt should equal "$3"
    End
  End

  Context '置換した文字列を再走査しないこと'
    Parameters
      ''
      -99
    End

    It '置換先にfromの文字を含められること'
      When call sx_str_tr_args res:cnt ab ab "$1" ::: bb aa
      The status should be success
      The variable res should equal bbaa
      The variable cnt should equal "'2'"
    End
  End

  Context '対応表の長さと重複'
    Parameters
      ''
      -99
    End

    It '不足した置換先の文字を削除して数えること'
      When call sx_str_tr_args res:cnt abca abc "$1" ::: XX
      The status should be success
      The variable res should equal XXXX
      The variable cnt should equal "'4'"
    End

    It '余剰の置換先を無視すること'
      When call sx_str_tr_args res:cnt ab ab "$1" ::: AA BB CC
      The status should be success
      The variable res should equal AABB
      The variable cnt should equal "'2'"
    End

    It 'fromが重複する場合は最初の位置を使用すること'
      When call sx_str_tr_args res:cnt aba aab "$1" ::: AA unused BB
      The status should be success
      The variable res should equal AABBAA
      The variable cnt should equal "'3'"
    End

    It '置換先なしでは対象文字をすべて削除すること'
      When call sx_str_tr_args res:cnt a1b2c3 abc "$1" :::
      The status should be success
      The variable res should equal 123
      The variable cnt should equal "'3'"
    End
  End

  It '区切りなしで置換先を省略できること'
    When call sx_str_tr_args res:cnt a1b2c3 abc
    The status should be success
    The variable res should equal 123
    The variable cnt should equal "'3'"
  End

  Context '無変換の入力'
    Parameters
      '' abc ''
      hello '' hello
      hello xyz hello
    End

    It '入力を保持して置換回数0を返すこと'
      When call sx_str_tr_args res:cnt "$1" "$2" AA BB CC
      The status should be success
      The variable res should equal "$3"
      The variable cnt should equal "'0'"
    End
  End

  It '空のバインド先でも成功すること'
    When call sx_str_tr_args '' ab ab AA BB
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It '結果だけをバインドできること'
    When call sx_str_tr_args res: ab ab AA BB
    The status should be success
    The variable res should equal AABB
  End

  It '回数だけをバインドできること'
    When call sx_str_tr_args :cnt ab ab AA BB
    The status should be success
    The variable cnt should equal "'2'"
  End

  It '単純な変数名では結果と回数をリストに蓄積すること'
    When call sx_str_tr_args res ab ab AA BB
    The status should be success
    The variable res should equal "'AABB' '2'"
  End

  It '入力と結果が同じ変数でも元の値を使用すること'
    res=ab
    When call sx_str_tr_args res: "$res" ab AA BB
    The status should be success
    The variable res should equal AABB
  End

  It '単一文字でも空の残余を扱えること'
    When call sx_str_tr_args res:cnt a a AA
    The status should be success
    The variable res should equal AA
    The variable cnt should equal "'1'"
  End

  It '二桁の位置パラメータを参照できること'
    When call sx_str_tr_args res:cnt lka abcdefghijkl A B C D E F G H I J K L
    The status should be success
    The variable res should equal LKA
    The variable cnt should equal "'3'"
  End

  Context 'fromの特殊文字'
    Parameters
      ''
      -99
    End

    It 'globの特殊文字を文字集合として扱うこと'
      When call sx_str_tr_args res:cnt 'a*?[]b' '*?[]' "$1" ::: STAR QUESTION OPEN CLOSE
      The status should be success
      The variable res should equal aSTARQUESTIONOPENCLOSEb
      The variable cnt should equal "'4'"
    End
  End

  It '引用符・glob・変数展開やコマンド置換に見える置換先をそのまま扱うこと'
    to1='"$HOME`false`$(false); *?[\'
    to2="a'b
c"
    When call sx_str_tr_args res:cnt ab ab "$to1" "$to2"
    The status should be success
    The variable res should equal "$to1$to2"
    The variable cnt should equal "'2'"
    The stdout should equal ''
    The stderr should equal ''
  End

  It '変更されたIFSに影響されず空白と空の置換先を保持すること'
    IFS=' :'
    When call sx_str_tr_args res:cnt abc abc ' A B ' '' ' C D '
    The status should be success
    The variable res should equal ' A B  C D '
    The variable cnt should equal "'3'"
  End

  It '日本語を文字単位で対応付けること'
    Skip if 'マルチバイト文字を文字単位で扱わない' multibyte_is_unavailable
    When call sx_str_tr_args res:cnt あいあ あい 東京 大阪
    The status should be success
    The variable res should equal 東京大阪東京
    The variable cnt should equal "'3'"
  End

  It '区切りの直後にある同じ値も置換先として保持すること'
    When call sx_str_tr_args res:cnt ab ab ::: ::: X
    The status should be success
    The variable res should equal ':::X'
    The variable cnt should equal "'2'"
  End

  It '後方の位置にある区切りと同じ値はデータとして扱うこと'
    When call sx_str_tr_args res:cnt abc abc A B :::
    The status should be success
    The variable res should equal 'AB:::'
    The variable cnt should equal "'3'"
  End

  Context '設定された区切り文字'
    Parameters
      '|'
      '*?['
      'X'
      'a b'
      '0'
    End

    It '区切りをリテラルとして認識すること'
      sxtest_run SX_CFG_SEP -- 'sx_cfg_set "$@"' "SEP=$1"
      When call sx_str_tr_args res:cnt ab ab -1 "$1" "$1" BB
      The status should be success
      The variable res should equal aBB
      The variable cnt should equal "'1'"
    End
  End

  Context '不正なlimit'
    Parameters
      00
      01
      --1
      1x
      '+'
      '-'
      1+1
    End

    It '結果を変更せず64を返すこと'
      res=before cnt=before
      When call sx_str_tr_args res:cnt abc abc "$1" ::: A B C
      The status should equal 64
      The variable res should equal before
      The variable cnt should equal before
    End
  End

  Context '不正なバインド形式'
    Parameters
      'invalid-name'
      '1invalid'
      'a b'
    End

    It '64を返すこと'
      When call sx_str_tr_args "$1" ab ab AA BB
      The status should equal 64
    End
  End

  It 'bindの省略を64で拒否すること'
    When call sx_str_tr_args
    The status should equal 64
  End

  It '文字列の省略を64で拒否すること'
    When call sx_str_tr_args res:
    The status should equal 64
  End

  It 'fromの省略を64で拒否すること'
    res=before
    When call sx_str_tr_args res: abc
    The status should equal 64
    The variable res should equal before
  End

  It '読み取り専用の結果を77で拒否すること'
    readonly res=before
    When call sx_str_tr_args res: ab ab AA BB
    The status should equal 77
    The variable res should equal before
  End

  It '読み取り専用の回数を77で拒否すること'
    res=before
    readonly cnt=before
    When call sx_str_tr_args res:cnt ab ab AA BB
    The status should equal 77
    The variable res should equal before
    The variable cnt should equal before
  End

  Context '参照設定の未設定'
    Parameters
      SX_CFG_SEP
      SX_CFG_NUM_RANGE
    End

    It '結果を変更せず78を返すこと'
      unset "$1"
      res=before
      When call sx_str_tr_args res: ab ab AA BB
      The status should equal 78
      The variable res should equal before
    End
  End

  It '空の区切り設定を78で拒否すること'
    SX_CFG_SEP=''
    res=before
    When call sx_str_tr_args res: ab ab AA BB
    The status should equal 78
    The variable res should equal before
  End

  It '検証省略時にも引数解析と後方置換を実行すること'
    SX_CFG_SKIP_CHK=1
    When call sx_str_tr_args res:cnt a1b2c3 abc -2 ::: AA '' CC
    The status should be success
    The variable res should equal a12CC3
    The variable cnt should equal "'2'"
  End
End
