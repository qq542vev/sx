#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_isep'
  Include ./sx.sh

  It 'interval=1 で引数間にセパレータを挿入してクォートすること'
    When call sx_arg_isep res "-" 1 ::: "a" "b" "c"
    The status should be success
    eval "set -- $res"
    The value "$1" should equal "a"
    The value "$2" should equal "-"
    The value "$3" should equal "b"
    The value "$4" should equal "-"
    The value "$5" should equal "c"
    The value "$#" should equal 5
  End

  It 'interval=2 で引数間にセパレータを挿入すること'
    When call sx_arg_isep res "-" 2 ::: "1" "2" "3" "4" "5"
    The status should be success
    eval "set -- $res"
    The value "$1" should equal "1"
    The value "$2" should equal "2"
    The value "$3" should equal "-"
    The value "$4" should equal "3"
    The value "$5" should equal "4"
    The value "$6" should equal "-"
    The value "$7" should equal "5"
    The value "$#" should equal 7
  End

  It 'interval=-2 (負のインターバル) で末尾から数えてセパレータを挿入すること'
    When call sx_arg_isep res "-" -2 ::: "1" "2" "3" "4" "5"
    The status should be success
    eval "set -- $res"
    The value "$1" should equal "1"
    The value "$2" should equal "-"
    The value "$3" should equal "2"
    The value "$4" should equal "3"
    The value "$5" should equal "-"
    The value "$6" should equal "4"
    The value "$7" should equal "5"
    The value "$#" should equal 7
  End

  It 'interval=-2 で要素数がインターバルの倍数の場合'
    When call sx_arg_isep res "-" -2 ::: "1" "2" "3" "4"
    The status should be success
    eval "set -- $res"
    The value "$1" should equal "1"
    The value "$2" should equal "2"
    The value "$3" should equal "-"
    The value "$4" should equal "3"
    The value "$5" should equal "4"
    The value "$#" should equal 5
  End

  It '引数がない場合は空文字を返すこと'
    When call sx_arg_isep res "-" 1 :::
    The status should be success
    The variable res should equal ""
  End

  It '引数が1つの場合はセパレータが挿入されないこと'
    When call sx_arg_isep res "-" 1 ::: "only"
    The status should be success
    The variable res should equal "'only'"
  End

  It 'interval=0 の場合はエラーになること'
    When call sx_arg_isep res "-" 0 ::: "a" "b"
    The status should equal 64
  End

  It '従来形式では $2 のみをセパレータとして扱うこと'
    When call sx_arg_isep res "-" "a" "b"
    The status should be success
    eval "set -- $res"
    The value "$1" should equal "a"
    The value "$2" should equal "-"
    The value "$3" should equal "b"
    The value "$#" should equal 3
  End

  Describe 'PRE / POST と limit の境界条件'
    It '負方向で limit=0 の場合、POST が挿入されないこと'
      When call sx_arg_isep res "@" -1 0 "$SX_ARG_ISEP_POST" ::: "a"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$#" should equal 1
    End

    It '負方向で limit=1 かつ PRE | POST の場合、POST のみが挿入されること'
      When call sx_arg_isep res "@" -1 1 "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "@"
      The value "$#" should equal 2
    End

    It '負方向で limit=2 かつ PRE | POST の場合、POST と PRE が挿入されること'
      When call sx_arg_isep res "@" -1 2 "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "@"
      The value "$2" should equal "a"
      The value "$3" should equal "@"
      The value "$#" should equal 3
    End

    It '負方向で limit=1 かつ PRE フラグがある場合、内部挿入が優先されること'
      # args: a, b. interval: -1 (内部1箇所). PREフラグあり. limit: 1.
      # 末尾に近い内部(a と b の間)が優先され、PRE は挿入されないはず。
      When call sx_arg_isep res "@" -1 1 "$SX_ARG_ISEP_PRE" ::: "a" "b"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "@"
      The value "$3" should equal "b"
      The value "$#" should equal 3
    End

    It '正方向で limit が PRE/POST を含む最大挿入数に制限されること'
      # 要素数3, interval 1 -> 内部2箇所. PRE/POST ありで計4箇所.
      # limit 10 を指定しても 4 回しか挿入されないはず
      When call sx_arg_isep res "-" 1 10 "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "-"
      The value "$2" should equal "a"
      The value "$3" should equal "-"
      The value "$4" should equal "b"
      The value "$5" should equal "-"
      The value "$6" should equal "c"
      The value "$7" should equal "-"
      The value "$#" should equal 7
    End

    It '負方向で limit が PRE/POST を含む最大挿入数に制限されること'
      # 要素数2, interval -1 -> 内部1箇所. PRE/POST ありで計3箇所.
      When call sx_arg_isep res "-" -1 10 "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "-"
      The value "$2" should equal "a"
      The value "$3" should equal "-"
      The value "$4" should equal "b"
      The value "$5" should equal "-"
      The value "$#" should equal 5
    End
  End

  It '特殊文字が含まれる場合でも正しくクォートされること'
    When call sx_arg_isep res " " 1 ::: "a'b" '"c"'
    The status should be success
    eval "set -- $res"
    The value "$1" should equal "a'b"
    The value "$2" should equal " "
    The value "$3" should equal '"c"'
  End

  It '読み取り専用変数に書き込もうとした場合にエラーになること'
    readonly ro_res_isep="fixed"
    When call sx_arg_isep ro_res_isep "-" 1 "a"
    The status should equal 77
  End

  Describe 'セパレータ (:::) 形式'
    It '最小構成 (res ::: a b c) で動作すること'
      When call sx_arg_isep res ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal ""
      The value "$3" should equal "b"
      The value "$4" should equal ""
      The value "$5" should equal "c"
    End

    It 'セパレータのみ指定 (res sep ::: a b c) で動作すること'
      When call sx_arg_isep res "-" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "-"
      The value "$3" should equal "b"
      The value "$4" should equal "-"
      The value "$5" should equal "c"
    End

    It 'フル指定 (res sep int ::: a b c) で動作すること'
      When call sx_arg_isep res "-" 2 ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "-"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
    End

    It 'データの中に ::: が含まれていても誤判定されないこと'
      When call sx_arg_isep res "-" 1 ::: "a" "b" ":::" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "-"
      The value "$3" should equal "b"
      The value "$4" should equal "-"
      The value "$5" should equal ":::"
      The value "$6" should equal "-"
      The value "$7" should equal "c"
    End

    It '新形式で不正なインターバルを指定した場合にエラーになること'
      When call sx_arg_isep res "-" "invalid" ::: "a" "b"
      The status should equal 64
    End

    It 'limit 指定 (res sep int lim ::: a b c d) で正方向の挿入回数が制限されること'
      When call sx_arg_isep res "-" 1 2 ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "-"
      The value "$3" should equal "b"
      The value "$4" should equal "-"
      The value "$5" should equal "c"
      The value "$6" should equal "d"
      The value "$#" should equal 6
    End

    It 'limit 指定 (res sep int lim ::: a b c d) で負方向の挿入回数が制限されること'
      When call sx_arg_isep res "-" -1 2 ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "-"
      The value "$4" should equal "c"
      The value "$5" should equal "-"
      The value "$6" should equal "d"
      The value "$#" should equal 6
    End

    It 'limit=0 の場合はセパレータが挿入されないこと'
      When call sx_arg_isep res "-" 1 0 ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It 'limit が最大分割数より大きい場合は制限がかからないこと'
      When call sx_arg_isep res "-" 1 10 ::: "a" "b"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "-"
      The value "$3" should equal "b"
      The value "$#" should equal 3
    End

    It '不正な limit を指定した場合にエラーになること'
      When call sx_arg_isep res "-" 1 "invalid" ::: "a" "b"
      The status should equal 64
    End
  End

  Describe 'bind (分配代入) 機能'
    It '分配代入 (v1:v2:rest) で結果を受け取れること'
      sx_arg_isep "v1:v2:rest" "-" 1 ::: "a" "b"
      The variable v1 should equal "a"
      The variable v2 should equal "-"
      The variable rest should equal "'b'"
    End

    It 'インターバルを跨ぐ分配代入が正しく動作すること'
      sx_arg_isep "v1:v2:v3:v4:v5" "-" 2 ::: "1" "2" "3"
      # Elements: "1", "2", "-", "3"
      The variable v1 should equal "1"
      The variable v2 should equal "2"
      The variable v3 should equal "-"
      The variable v4 should equal "3"
      The variable v5 should equal ""
    End

    It 'スキップを含む分配代入ができること'
      sx_arg_isep "::v3" "-" 1 ::: "a" "b"
      # Elements: "a", "-", "b"
      The variable v1 should be undefined
      The variable v2 should be undefined
      The variable v3 should equal "'b'"
    End
  End

  Describe 'SX_ARG_ISEP_PRE / POST フラグ'
    It 'Forward PRE で先頭にセパレータを挿入すること'
      When call sx_arg_isep res "-" 1 "" "$SX_ARG_ISEP_PRE" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "-"
      The value "$2" should equal "a"
      The value "$3" should equal "-"
      The value "$4" should equal "b"
      The value "$5" should equal "-"
      The value "$6" should equal "c"
      The value "$#" should equal 6
    End

    It 'Forward POST で末尾にセパレータを挿入すること (偶数分割)'
      When call sx_arg_isep res "-" 2 "" "$SX_ARG_ISEP_POST" ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "-"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$6" should equal "-"
      The value "$#" should equal 6
    End

    It 'Forward POST で末尾にセパレータを挿入しないこと (奇数分割)'
      When call sx_arg_isep res "-" 2 "" "$SX_ARG_ISEP_POST" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "-"
      The value "$4" should equal "c"
      The value "$#" should equal 4
    End

    It 'Forward PRE|POST で両端にセパレータを挿入すること'
      When call sx_arg_isep res "-" 1 "" "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "-"
      The value "$2" should equal "a"
      The value "$3" should equal "-"
      The value "$4" should equal "b"
      The value "$5" should equal "-"
      The value "$#" should equal 5
    End

    It 'Backward POST で末尾にセパレータを挿入すること'
      When call sx_arg_isep res "-" -2 "" "$SX_ARG_ISEP_POST" ::: "a" "b" "c" "d" "e"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "-"
      The value "$3" should equal "b"
      The value "$4" should equal "c"
      The value "$5" should equal "-"
      The value "$6" should equal "d"
      The value "$7" should equal "e"
      The value "$8" should equal "-"
      The value "$#" should equal 8
    End

    It 'Backward PRE で先頭にセパレータを挿入すること (偶数分割)'
      When call sx_arg_isep res "-" -2 "" "$SX_ARG_ISEP_PRE" ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "-"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$4" should equal "-"
      The value "$5" should equal "c"
      The value "$6" should equal "d"
      The value "$#" should equal 6
    End

    It 'Backward PRE で先頭にセパレータを挿入しないこと (奇数分割)'
      When call sx_arg_isep res "-" -2 "" "$SX_ARG_ISEP_PRE" ::: "a" "b" "c" "d" "e"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "-"
      The value "$3" should equal "b"
      The value "$4" should equal "c"
      The value "$5" should equal "-"
      The value "$6" should equal "d"
      The value "$7" should equal "e"
      The value "$#" should equal 7
    End

    It 'Backward PRE|POST で両端にセパレータを挿入すること (偶数分割)'
      When call sx_arg_isep res "-" -2 "" "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "-"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$4" should equal "-"
      The value "$5" should equal "c"
      The value "$6" should equal "d"
      The value "$7" should equal "-"
      The value "$#" should equal 7
    End

    It 'Backward POST では lim が消費されること'
      When call sx_arg_isep res "-" -2 1 "$SX_ARG_ISEP_POST" ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$4" should equal "d"
      The value "$5" should equal "-"
      The value "$#" should equal 5
    End

    It 'Forward PRE で lim が消費されること'
      When call sx_arg_isep res "-" 1 1 "$SX_ARG_ISEP_PRE" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "-"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$4" should equal "c"
      The value "$#" should equal 4
    End

    It 'Forward POST は lim を消費しないこと'
      When call sx_arg_isep res "-" 2 1 "$SX_ARG_ISEP_POST" ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "-"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$#" should equal 5
    End

    It 'limit=0 では PRE が挿入されないこと'
      When call sx_arg_isep res "-" 1 0 "$SX_ARG_ISEP_PRE" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It 'limit=0 では POST が挿入されないこと'
      When call sx_arg_isep res "-" 2 0 "$SX_ARG_ISEP_POST" ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$4" should equal "d"
      The value "$#" should equal 4
    End

    It 'インターバルより少ない要素数でも PRE で挿入されること'
      When call sx_arg_isep res "-" 5 "" "$SX_ARG_ISEP_PRE" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "-"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$4" should equal "c"
      The value "$#" should equal 4
    End

    It 'フル指定 (res sep int lim flags :::) で PRE/POST が動作すること'
      When call sx_arg_isep res "-" 1 2 "$SX_ARG_ISEP_PRE" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "-"
      The value "$2" should equal "a"
      The value "$3" should equal "-"
      The value "$4" should equal "b"
      The value "$5" should equal "c"
      The value "$#" should equal 5
    End

    It '不正な flags 値でエラーになること'
      When call sx_arg_isep res "-" 1 "" "invalid" ::: "a" "b"
      The status should equal 64
    End

    It '負方向で POST が lim を消費し内部分割が減ること'
      When call sx_arg_isep res "-" -2 2 "$SX_ARG_ISEP_POST" ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "-"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$6" should equal "-"
      The value "$#" should equal 6
    End

    It '負方向で PRE 挿入が limit を消費すること'
      # args: a, b. interval: -2. PREフラグあり. limit: 2.
      # 内部挿入(b|c)と PRE(before a) の両方が挿入されるケース。
      When call sx_arg_isep res "-" -2 2 "$SX_ARG_ISEP_PRE" ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "-"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$4" should equal "-"
      The value "$5" should equal "c"
      The value "$6" should equal "d"
      The value "$#" should equal 6
    End
  End

End
