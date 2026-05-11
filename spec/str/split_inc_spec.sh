#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_split (SX_STR_SPLIT_INC)'
  Include ./sx.sh

  It '通常文字での INC 動作確認（前方分割）'
    When call sx_str_split res "A:B:C" ":" "${SX_NUM_I32_MAX}" "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'A' ':' 'B' ':' 'C'"
  End

  It '通常文字での INC 動作確認（後方分割）'
    When call sx_str_split res "A:B:C" ":" -${SX_NUM_I32_MAX} "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'A' ':' 'B' ':' 'C'"
  End

  It 'GLOB パターンでの INC 動作確認（前方分割）'
    When call sx_str_split res "A1B2C" "[0-9]" "${SX_NUM_I32_MAX}" "$((SX_STR_SPLIT_GLOB | SX_STR_SPLIT_INC))"
    The status should be success
    The variable res should equal "'A' '1' 'B' '2' 'C'"
  End

  It 'GLOB パターンでの INC 動作確認（後方分割）'
    When call sx_str_split res "A1B2C" "[0-9]" -${SX_NUM_I32_MAX} "$((SX_STR_SPLIT_GLOB | SX_STR_SPLIT_INC))"
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

  It '空文字区切りでの INC 無視（既存挙動維持）'
    When call sx_str_split res "ABC" "" "${SX_NUM_I32_MAX}" "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'' 'A' 'B' 'C' ''"
  End

  It '連続する区切り文字の処理確認'
    When call sx_str_split res "A::B" ":" "${SX_NUM_I32_MAX}" "${SX_STR_SPLIT_INC}"
    The status should be success
    The variable res should equal "'A' ':' '' ':' 'B'"
  End
End
