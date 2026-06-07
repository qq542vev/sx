#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_isep'
  Include ./sx.sh

  It 'interval=1 で文字列の各文字間にセパレータを挿入すること'
    When call sx_str_isep res "abc" "-" 1
    The status should be success
    The variable res should equal "a-b-c"
  End

  It 'interval=2 で2文字ごとにセパレータを挿入すること'
    When call sx_str_isep res "123456" "-" 2
    The status should be success
    The variable res should equal "12-34-56"
  End

  It 'interval=2 で奇数長の文字列を処理すること'
    When call sx_str_isep res "12345" "-" 2
    The status should be success
    The variable res should equal "12-34-5"
  End

  It 'interval=-2 (負のインターバル) で末尾から数えてセパレータを挿入すること'
    When call sx_str_isep res "12345" "-" -2
    The status should be success
    The variable res should equal "1-23-45"
  End

  It 'interval=-2 で文字列長がインターバルの倍数の場合'
    When call sx_str_isep res "1234" "-" -2
    The status should be success
    The variable res should equal "12-34"
  End

  It 'limit=1 で挿入回数を制限すること'
    When call sx_str_isep res "123456" "-" 2 1
    The status should be success
    The variable res should equal "12-3456"
  End

  It '負のインターバルで limit=1 の場合'
    When call sx_str_isep res "123456" "-" -2 1
    The status should be success
    The variable res should equal "1234-56"
  End

  It '空文字列を処理できること'
    When call sx_str_isep res "" "-" 1
    The status should be success
    The variable res should equal ""
  End

  It '文字列が1文字の場合はセパレータが挿入されないこと'
    When call sx_str_isep res "a" "-" 1
    The status should be success
    The variable res should equal "a"
  End

  It 'インターバルが文字列長より長い場合はセパレータが挿入されないこと'
    When call sx_str_isep res "abc" "-" 5
    The status should be success
    The variable res should equal "abc"
  End

  It 'デフォルトのインターバルは 1 であること'
    When call sx_str_isep res "abc" "-"
    The status should be success
    The variable res should equal "a-b-c"
  End

  It 'interval=0 の場合はエラーになること'
    When call sx_str_isep res "abc" "-" 0
    The status should equal 64
  End

  It '読み取り専用変数に書き込もうとした場合にエラーになること'
    readonly ro_res_isep="fixed"
    When call sx_str_isep ro_res_isep "abc" "-" 1
    The status should equal 77
  End

  It '特殊文字を含むセパレータを処理できること'
    When call sx_str_isep res "abc" "' " 1
    The status should be success
    The variable res should equal "a' b' c"
  End

  It 'interval=INT_MIN (-2147483648) の場合に早期終了すること'
    When call sx_str_isep res "abc" "-" -2147483648
    The status should be success
    The variable res should equal "abc"
  End

  It 'interval=文字列長 の場合に早期終了すること (Forward)'
    When call sx_str_isep res "abc" "-" 3
    The status should be success
    The variable res should equal "abc"
  End

  It 'interval=-文字列長 の場合に早期終了すること (Backward)'
    When call sx_str_isep res "abc" "-" -3
    The status should be success
    The variable res should equal "abc"
  End

  It '非常に大きなインターバルの場合に早期終了すること'
    When call sx_str_isep res "abc" "-" 1000000
    The status should be success
    The variable res should equal "abc"
    End

  It 'limit が負の場合はエラー (EX_USAGE) になること'
    When call sx_str_isep res "abc" "-" 1 -1
    The status should be failure
    The status should equal 64
  End

  Context 'SX_STR_ISEP_PRE / POST フラグ'
    It 'SX_STR_ISEP_PRE で先頭にセパレータを挿入すること (Forward)'
      When call sx_str_isep res "abc" "-" 1 "" "$SX_STR_ISEP_PRE"
      The status should be success
      The variable res should equal "-a-b-c"
    End

    It 'SX_STR_ISEP_POST で末尾にセパレータを挿入すること (Forward, 割り切れる場合)'
      When call sx_str_isep res "abc" "-" 1 "" "$SX_STR_ISEP_POST"
      The status should be success
      The variable res should equal "a-b-c-"
    End

    It 'SX_STR_ISEP_POST で末尾にセパレータを挿入しないこと (Forward, 割り切れない場合)'
      When call sx_str_isep res "12345" "-" 2 "" "$SX_STR_ISEP_POST"
      The status should be success
      The variable res should equal "12-34-5"
    End

    It 'SX_STR_ISEP_POST で末尾にセパレータを挿入すること (Forward, 割り切れる場合, int=2)'
      When call sx_str_isep res "123456" "-" 2 "" "$SX_STR_ISEP_POST"
      The status should be success
      The variable res should equal "12-34-56-"
    End

    It 'SX_STR_ISEP_POST で末尾にセパレータを挿入すること (Backward)'
      When call sx_str_isep res "12345" "-" -2 "" "$SX_STR_ISEP_POST"
      The status should be success
      The variable res should equal "1-23-45-"
    End

    It 'SX_STR_ISEP_PRE で先頭にセパレータを挿入しないこと (Backward, 割り切れない場合)'
      When call sx_str_isep res "12345" "-" -2 "" "$SX_STR_ISEP_PRE"
      The status should be success
      The variable res should equal "1-23-45"
    End

    It 'SX_STR_ISEP_PRE で先頭にセパレータを挿入すること (Backward, 割り切れる場合)'
      When call sx_str_isep res "123456" "-" -2 "" "$SX_STR_ISEP_PRE"
      The status should be success
      The variable res should equal "-12-34-56"
    End

    It '空文字列に対して PRE|POST を指定した場合'
      When call sx_str_isep res "" "-" 1 "" $((SX_STR_ISEP_PRE | SX_STR_ISEP_POST))
      The status should be success
      The variable res should equal "-"
    End

    It '空文字列に対して負のインターバルで PRE|POST を指定した場合'
      When call sx_str_isep res "" "-" -1 "" $((SX_STR_ISEP_PRE | SX_STR_ISEP_POST))
      The status should be success
      The variable res should equal "-"
    End

    It 'インターバルより短い文字列でも PRE で挿入されること'
      When call sx_str_isep res "abc" "-" 5 "" "$SX_STR_ISEP_PRE"
      The status should be success
      The variable res should equal "-abc"
    End

    It 'limit が PRE で消費されること'
      When call sx_str_isep res "abc" "-" 1 1 "$SX_STR_ISEP_PRE"
      The status should be success
      The variable res should equal "-abc"
    End

    It 'glob 特殊文字を含む文字列を正しく処理できること (Backward)'
      When call sx_str_isep res "[*]" "-" -1
      The status should be success
      The variable res should equal "[-*-]"
    End

    It 'Forward: limit が POST 境界で正しく機能すること'
      When call sx_str_isep res "abcd" "-" 2 2 "$SX_STR_ISEP_POST"
      The status should be success
      The variable res should equal "ab-cd-"
    End

    It 'Forward: limit が POST 境界の手前で正しく機能すること'
      When call sx_str_isep res "abcd" "-" 2 1 "$SX_STR_ISEP_POST"
      The status should be success
      The variable res should equal "ab-cd"
    End

    It 'Backward: limit が PRE 境界で正しく機能すること'
      When call sx_str_isep res "1234" "-" -2 2 "$SX_STR_ISEP_PRE"
      The status should be success
      The variable res should equal "-12-34"
    End

    It 'Backward: limit が PRE 境界の手前で正しく機能すること'
      When call sx_str_isep res "1234" "-" -2 1 "$SX_STR_ISEP_PRE"
      The status should be success
      The variable res should equal "12-34"
    End
  End
End
