#!/bin/sh
# shellcheck shell=sh disable=SC2154
# 共通実装を単独の個別モジュールとして検証する。

Describe '__sx_str_tr0'
  sxtest_load ./build/modules/__sx_str_tr0.sh

  Context '分割済みの対応表'
    Parameters
      '' AA12CC3AA "'4'"
      2 AA12c3a "'2'"
      -2 a1b2CC3AA "'2'"
      0 a1b2c3a "'0'"
      -0 a1b2c3a "'0'"
      999999999999999999999999999999 AA12CC3AA "'4'"
      -999999999999999999999999999999 AA12CC3AA "'4'"
    End

    It '正規化済みの引数で前後の置換と削除ができること'
      When call __sx_str_tr0 res:cnt a1b2c3a abc "$1" AA '' CC
      The status should be success
      The variable res should equal "$2"
      The variable cnt should equal "$3"
    End
  End

  Context '無変換の入力'
    Parameters
      '' abc ''
      hello '' hello
      hello xyz hello
    End

    It '結果をバインドして成功終了すること'
      When call __sx_str_tr0 res:cnt "$1" "$2" '' AA BB CC
      The status should be success
      The variable res should equal "$3"
      The variable cnt should equal "'0'"
    End
  End

  It '置換先の不足を削除として扱うこと'
    When call __sx_str_tr0 res:cnt abca abc '' XX
    The status should be success
    The variable res should equal XXXX
    The variable cnt should equal "'4'"
  End

  It '置換先を省略できること'
    When call __sx_str_tr0 res:cnt a1b2c3 abc ''
    The status should be success
    The variable res should equal 123
    The variable cnt should equal "'3'"
  End

  It 'limit位置や区切り文字に見える置換先もデータとして扱うこと'
    When call __sx_str_tr0 res:cnt ab ab '' 1 :::
    The status should be success
    The variable res should equal '1:::'
    The variable cnt should equal "'2'"
  End

  It '重複したfromの最初の位置を使うこと'
    When call __sx_str_tr0 res:cnt aba aab -9 AA unused BB
    The status should be success
    The variable res should equal AABBAA
    The variable cnt should equal "'3'"
  End

  It '二桁の位置パラメータを参照できること'
    When call __sx_str_tr0 res:cnt lka abcdefghijkl -9 A B C D E F G H I J K L
    The status should be success
    The variable res should equal LKA
    The variable cnt should equal "'3'"
  End

  It 'バインド先が結果だけでも成功すること'
    When call __sx_str_tr0 res: ab ab '' AA BB
    The status should be success
    The variable res should equal AABB
  End
End
