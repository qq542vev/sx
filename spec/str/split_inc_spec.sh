#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_split (SX_STR_SPLIT_INC)'
  sxtest_load ./build/modules/sx_str_split.sh

  It '通常文字での INC 動作確認（前方分割）'
    When call sx_str_split res "A:B:C" ":" 2147483647 "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'A' ':' 'B' ':' 'C'"
  End

  It '通常文字での INC 動作確認（後方分割）'
    When call sx_str_split res "A:B:C" ":" -2147483647 "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'A' ':' 'B' ':' 'C'"
  End

  It 'GLOB パターンでの INC 動作確認（前方分割）'
    When call sx_str_split res "A1B2C" "[0-9]" 2147483647 "$((SX_STR_SPLIT_GLOB | SX_STR_SPLIT_INC))"
    The status should be success
    The variable res should equal "'A' '1' 'B' '2' 'C'"
  End

  It 'GLOB パターンでの INC 動作確認（後方分割）'
    When call sx_str_split res "A1B2C" "[0-9]" -2147483647 "$((SX_STR_SPLIT_GLOB | SX_STR_SPLIT_INC))"
    The status should be success
    The variable res should equal "'A' '1' 'B' '2' 'C'"
  End

  It '制限付き前方分割での INC 動作確認'
    When call sx_str_split res "A:B:C:D" ":" 2 "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'A' ':' 'B' ':' 'C:D'"
  End

  It '制限付き後方分割での INC 動作確認'
    When call sx_str_split res "A:B:C:D" ":" -2 "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'A:B' ':' 'C' ':' 'D'"
  End

  It '空文字区切りでの INC 動作確認'
    When call sx_str_split res "ABC" "" 2147483647 "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'' '' 'A' '' 'B' '' 'C' '' ''"
  End

  It '空文字区切りでの INC 動作確認（制限付き前方分割）'
    When call sx_str_split res "A" "" 1 "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'' '' 'A'"
  End

  It '空文字区切りでの INC 動作確認（制限付き後方分割）'
    When call sx_str_split res "A" "" -1 "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'A' '' ''"
  End

  It '空文字区切りでの INC 動作確認（空文字列）'
    When call sx_str_split res "" "" 1 "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'' '' ''"
  End

  Context 'データ中のメタ文字と実区切りの抽出'
    Parameters
      'a*1b' 1 "'a*' '1' 'b'"
      'a*1b' -1 "'a*' '1' 'b'"
      'a1*b' 1 "'a' '1' '*b'"
      'a1*b' -1 "'a' '1' '*b'"
      'a[xy]1b' 1 "'a[xy]' '1' 'b'"
      'a1[xy]b' -1 "'a' '1' '[xy]b'"
    End

    It '前後のデータをパターンとして再解釈しないこと'
      When call sx_str_split res "$1" '[0-9]' "$2" "$((SX_STR_SPLIT_GLOB | SX_STR_SPLIT_INC))"
      The status should be success
      The variable res should equal "$3"
    End
  End

  It '複数文字のglob一致でも実際の区切りだけを含めること'
    When call sx_str_split res 'a*12?b' '[0-9][0-9]' -1 "$((SX_STR_SPLIT_GLOB | SX_STR_SPLIT_INC))"
    The status should be success
    The variable res should equal "'a*' '12' '?b'"
  End

  It '連続する区切り文字の処理確認'
    When call sx_str_split res "A::B" ":" 2147483647 "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'A' ':' '' ':' 'B'"
  End
End
