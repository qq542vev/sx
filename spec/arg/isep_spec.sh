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

  It 'bind引数のみを消費し、$2以降はデータとして扱われること'
    When call sx_arg_isep res "-" "a" "b"
    The status should be success
    eval "set -- $res"
    The value "$1" should equal "-"
    The value "$2" should equal ""
    The value "$3" should equal "a"
    The value "$4" should equal ""
    The value "$5" should equal "b"
    The value "$#" should equal 5
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

    It '引数が空で 正のインターバル、PRE|POST の場合、セパレータが1つだけ出力されること'
      When call sx_arg_isep r1 x 1 10 "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" :::
      The status should be success
      The variable r1 should equal "'x'"
    End

    It '引数が空で 負のインターバル、PRE|POST の場合、セパレータが1つだけ出力されること'
      When call sx_arg_isep r2 x -1 10 "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" :::
      The status should be success
      The variable r2 should equal "'x'"
    End

    It '引数が空で 正のインターバル、PRE のみの場合、セパレータが1つ出力されること'
      When call sx_arg_isep res x 1 10 "$SX_ARG_ISEP_PRE" :::
      The status should be success
      The variable res should equal "'x'"
    End

    It '引数が空で 負のインターバル、PRE のみの場合、何も出力されないこと'
      When call sx_arg_isep res x -1 10 "$SX_ARG_ISEP_PRE" :::
      The status should be success
      The variable res should equal ""
    End

    It '引数が空で 正のインターバル、POST のみの場合、何も出力されないこと'
      When call sx_arg_isep res x 1 10 "$SX_ARG_ISEP_POST" :::
      The status should be success
      The variable res should equal ""
    End

    It '引数が空で 負のインターバル、POST のみの場合、セパレータが1つ出力されること'
      When call sx_arg_isep res x -1 10 "$SX_ARG_ISEP_POST" :::
      The status should be success
      The variable res should equal "'x'"
    End

    It '引数が空で 正のインターバル、フラグなしの場合、何も出力されないこと'
      When call sx_arg_isep res x 1 10 "" :::
      The status should be success
      The variable res should equal ""
    End

    It '引数が空で 負のインターバル、フラグなしの場合、何も出力されないこと'
      When call sx_arg_isep res x -1 10 "" :::
      The status should be success
      The variable res should equal ""
    End
  End

  Describe 'コールバックモード (CB)'
    It '正方向 (int=1) で値間にコールバック結果が挿入されること'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 1 "" "$SX_ARG_ISEP_CB" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "(@1)"
      The value "$3" should equal "b"
      The value "$4" should equal "(@2)"
      The value "$5" should equal "c"
      The value "$#" should equal 5
    End

    It '正方向 (int=2) で2つおきにコールバック結果が挿入されること'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 2 "" "$SX_ARG_ISEP_CB" ::: "1" "2" "3" "4" "5"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "1"
      The value "$2" should equal "2"
      The value "$3" should equal "(@1)"
      The value "$4" should equal "3"
      The value "$5" should equal "4"
      The value "$6" should equal "(@2)"
      The value "$7" should equal "5"
      The value "$#" should equal 7
    End

    It 'int=3 でPRE|POST、内部挿入位置が正しいこと'
      cb() { __sx_var_set "${1}=($3)"; }
      When call sx_arg_isep res cb 3 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "1" "2" "3" "4" "5" "6"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(1)"
      The value "$2" should equal "1"
      The value "$3" should equal "2"
      The value "$4" should equal "3"
      The value "$5" should equal "(2)"
      The value "$6" should equal "4"
      The value "$7" should equal "5"
      The value "$8" should equal "6"
      The value "$9" should equal "(3)"
      The value "$#" should equal 9
    End

    It 'PRE フラグで先頭にコールバック結果が挿入されること'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 1 "" "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(@1)"
      The value "$2" should equal "a"
      The value "$3" should equal "(@2)"
      The value "$4" should equal "b"
      The value "$#" should equal 4
    End

    It 'PRE のみ: 要素が1つでもPREが挿入されること'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 1 "" "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "only"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(@1)"
      The value "$2" should equal "only"
      The value "$#" should equal 2
    End

    It 'PRE のみ: int が要素数より大きくてもPREが挿入されること'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 5 "" "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(@1)"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$#" should equal 3
    End

    It 'POST フラグで末尾にコールバック結果が挿入されること (偶数分割)'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 2 "" "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "(@1)"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$6" should equal "(@2)"
      The value "$#" should equal 6
    End

    It 'POST フラグで末尾に挿入されないこと (奇数分割)'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 2 "" "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "(@1)"
      The value "$4" should equal "c"
      The value "$#" should equal 4
    End

    It 'POST のみ: int が要素数より大きい場合は何も挿入されないこと'
      cb() { __sx_var_set "${1}=x"; }
      When call sx_arg_isep res cb 5 "" "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$#" should equal 2
    End

    It 'PRE|POST で両端にコールバック結果が挿入されること'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "x"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(@1)"
      The value "$2" should equal "x"
      The value "$3" should equal "(@2)"
      The value "$#" should equal 3
    End

    It 'limit で内部挿入回数が制限されること'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 1 2 "$SX_ARG_ISEP_CB" ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "(@1)"
      The value "$3" should equal "b"
      The value "$4" should equal "(@2)"
      The value "$5" should equal "c"
      The value "$6" should equal "d"
      The value "$#" should equal 6
    End

    It 'limit=0 では一切挿入されないこと'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 1 0 "$SX_ARG_ISEP_CB" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It 'limit=1 で PRE が優先され内部が挿入されないこと'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 1 1 "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(@1)"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$#" should equal 3
    End

    It 'limit=1 で内部は挿入されるが POST は挿入されないこと'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 1 1 "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "(@1)"
      The value "$3" should equal "b"
      The value "$#" should equal 3
    End

    It 'PRE|POST と limit=1 で PRE のみ挿入されること'
      cb() { __sx_var_set "${1}=(@$3)"; }
      When call sx_arg_isep res cb 1 1 \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(@1)"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$#" should equal 3
    End

    It 'コールバックが非0を返すと以後の内部挿入が中断されること'
      cb_stop() {
        __sx_var_set "${1}=!"
        case "$3" in 2) return 1;; esac
      }
      When call sx_arg_isep res cb_stop 2 "" "$SX_ARG_ISEP_CB" ::: "1" "2" "3" "4" "5" "6"
      The status should equal 1
      eval "set -- $res"
      The value "$1" should equal "1"
      The value "$2" should equal "2"
      The value "$3" should equal "!"
      The value "$4" should equal "3"
      The value "$5" should equal "4"
      The value "$6" should equal "5"
      The value "$7" should equal "6"
      The value "$#" should equal 7
    End

    It 'PRE コールバックが失敗すると内部/POSTも挿入されないこと'
      cb_fail() { __sx_var_set "${1}=X"; return 1; }
      stat=0
      sx_arg_isep res cb_fail 1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b" || stat=$?
      The variable stat should equal 1
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$#" should equal 2
    End

    It 'POST コールバックが失敗しても内部/PREの値は挿入され、ステータスはエラーになること'
      cb_fail_post() {
        case "$3" in
          3) __sx_var_set "${1}=!"; return 1;;
          *) __sx_var_set "${1}=($3)";;
        esac
      }
      When call sx_arg_isep res cb_fail_post 1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should equal 1
      eval "set -- $res"
      The value "$1" should equal "(1)"
      The value "$2" should equal "a"
      The value "$3" should equal "(2)"
      The value "$4" should equal "b"
      The value "$#" should equal 4
    End

    It 'コールバックエラーが status に伝搬されること'
      cb_err() { __sx_var_set "${1}=E"; return 42; }
      When call sx_arg_isep res cb_err 1 "" "$SX_ARG_ISEP_CB" ::: "a" "b"
      The status should equal 42
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$#" should equal 2
    End

    It 'count 引数が PRE→内部→POST で連続して増加すること'
      cb_cnt() { __sx_var_set "${1}=C$3"; }
      When call sx_arg_isep res cb_cnt 2 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "C1"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$4" should equal "C2"
      The value "$5" should equal "c"
      The value "$6" should equal "d"
      The value "$7" should equal "C3"
      The value "$#" should equal 7
    End

    It 'slot 引数が正方向で左基準の境界番号になること'
      cb_slot() { __sx_var_set "${1}=S${2}C${3}K${4}"; }
      When call sx_arg_isep res cb_slot 2 "" "$SX_ARG_ISEP_CB" ::: "a" "b" "c" "d" "f"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "S2C1K0"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$6" should equal "S4C2K0"
      The value "$7" should equal "f"
      The value "$#" should equal 7
    End

    It 'slot 引数が負方向でも左基準の境界番号になること'
      cb_slot() { __sx_var_set "${1}=S${2}C${3}K${4}"; }
      When call sx_arg_isep res cb_slot -2 "" "$SX_ARG_ISEP_CB" ::: "a" "b" "c" "d" "f"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "S1C2K0"
      The value "$3" should equal "b"
      The value "$4" should equal "c"
      The value "$5" should equal "S3C1K0"
      The value "$6" should equal "d"
      The value "$7" should equal "f"
      The value "$#" should equal 7
    End

    It 'skip 引数がこの呼び出し前までの未挿入回数になること'
      cb_skip() {
        case "$3" in
          1|3) :;;
          *) __sx_var_set "${1}=S${2}C${3}K${4}";;
        esac
      }
      When call sx_arg_isep res cb_skip 1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "S1C2K1"
      The value "$3" should equal "b"
      The value "$4" should equal "c"
      The value "$5" should equal "S3C4K2"
      The value "$#" should equal 5
    End

    It 'コールバックが挿入されないケースでも count が正しいこと'
      cb_cnt2() { __sx_var_set "${1}=C$3"; }
      When call sx_arg_isep res cb_cnt2 1 "" "$SX_ARG_ISEP_CB" ::: "x"
      The status should be success
      The variable res should equal "'x'"
    End

    It '分配代入 (bind) とコールバックが併用できること'
      cb() { __sx_var_set "${1}=(@$3)"; }
      sx_arg_isep "v1:v2:rest" cb 1 "" "$SX_ARG_ISEP_CB" ::: "a" "b"
      The variable v1 should equal "a"
      The variable v2 should equal "(@1)"
      The variable rest should equal "'b'"
    End

    It 'スキップを含む分配代入とコールバックが併用できること'
      cb() { __sx_var_set "${1}=SEP"; }
      sx_arg_isep "::v3" cb 1 "" "$SX_ARG_ISEP_CB" ::: "a" "b"
      The variable v1 should be undefined
      The variable v2 should be undefined
      The variable v3 should equal "'b'"
    End

    It '引数がない場合は空文字を返すこと'
      cb() { __sx_var_set "${1}=x"; }
      When call sx_arg_isep res cb 1 "" "$SX_ARG_ISEP_CB" :::
      The status should be success
      The variable res should equal ""
    End

    It '引数が1つの場合はセパレータが挿入されないこと'
      cb() { __sx_var_set "${1}=x"; }
      When call sx_arg_isep res cb 1 "" "$SX_ARG_ISEP_CB" ::: "only"
      The status should be success
      The variable res should equal "'only'"
    End

    It '特殊文字が含まれていても正しく処理されること (CB + PRE|POST)'
      cb() { __sx_var_set "${1}=[@$3]"; }
      When call sx_arg_isep res cb 1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "hello world" "foo'bar"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "[@1]"
      The value "$2" should equal "hello world"
      The value "$3" should equal "[@2]"
      The value "$4" should equal "foo'bar"
      The value "$5" should equal "[@3]"
      The value "$#" should equal 5
    End

    It '読み取り専用変数に書き込もうとした場合にエラーになること'
      cb() { __sx_var_set "${1}=x"; }
      readonly ro_res_isep_cb="fixed"
      When call sx_arg_isep ro_res_isep_cb cb 1 "" "$SX_ARG_ISEP_CB" ::: "a"
      The status should equal 77
    End

    Context '引数が空の場合の挙動 (CB)'
      It '引数が空で 正のインターバル、PRE|POST|CB の場合、セパレータが1つだけ出力されること'
        cb() { __sx_var_set "${1}=X${3}"; }
        When call sx_arg_isep res cb 1 10 "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST | SX_ARG_ISEP_CB))" :::
        The status should be success
        The variable res should equal "'X1'"
      End

      It '引数が空で 負のインターバル、PRE|POST|CB の場合、セパレータが1つだけ出力されること'
        cb() { __sx_var_set "${1}=X${3}"; }
        When call sx_arg_isep res cb -1 10 "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST | SX_ARG_ISEP_CB))" :::
        The status should be success
        The variable res should equal "'X1'"
      End

      It '引数が空で 正のインターバル、PRE|CB の場合、セパレータが1つ出力されること'
        cb() { __sx_var_set "${1}=X${3}"; }
        When call sx_arg_isep res cb 1 10 "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_CB))" :::
        The status should be success
        The variable res should equal "'X1'"
      End

      It '引数が空で 負のインターバル、PRE|CB の場合、何も出力されないこと'
        cb() { __sx_var_set "${1}=X${3}"; }
        When call sx_arg_isep res cb -1 10 "$((SX_ARG_ISEP_PRE | SX_ARG_ISEP_CB))" :::
        The status should be success
        The variable res should equal ""
      End

      It '引数が空で 正のインターバル、POST|CB の場合、何も出力されないこと'
        cb() { __sx_var_set "${1}=X${3}"; }
        When call sx_arg_isep res cb 1 10 "$((SX_ARG_ISEP_POST | SX_ARG_ISEP_CB))" :::
        The status should be success
        The variable res should equal ""
      End

      It '引数が空で 負のインターバル、POST|CB の場合、セパレータが1つ出力されること'
        cb() { __sx_var_set "${1}=X${3}"; }
        When call sx_arg_isep res cb -1 10 "$((SX_ARG_ISEP_POST | SX_ARG_ISEP_CB))" :::
        The status should be success
        The variable res should equal "'X1'"
      End

      It '引数が空で 正のインターバル、CBのみ（フラグなし）の場合、何も出力されないこと'
        cb() { __sx_var_set "${1}=X${3}"; }
        When call sx_arg_isep res cb 1 10 "$SX_ARG_ISEP_CB" :::
        The status should be success
        The variable res should equal ""
      End
    End

    Context 'PRE + limit 境界 (int=2)'
      It 'int=2, PRE|POST, lim=1, 4要素 → PRE のみ挿入されること'
        cb() { __sx_var_set "${1}=(@$3)"; }
        When call sx_arg_isep res cb 2 1 \
          "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b" "c" "d"
        The status should be success
        eval "set -- $res"
        The value "$1" should equal "(@1)"
        The value "$2" should equal "a"
        The value "$3" should equal "b"
        The value "$4" should equal "c"
        The value "$5" should equal "d"
        The value "$#" should equal 5
      End

      It 'int=2, PRE|POST, lim=2, 4要素 → PRE + 内部1つ (POST無)'
        cb() { __sx_var_set "${1}=(@$3)"; }
        When call sx_arg_isep res cb 2 2 \
          "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b" "c" "d"
        The status should be success
        eval "set -- $res"
        The value "$1" should equal "(@1)"
        The value "$2" should equal "a"
        The value "$3" should equal "b"
        The value "$4" should equal "(@2)"
        The value "$5" should equal "c"
        The value "$6" should equal "d"
        The value "$#" should equal 6
      End
    End
  End

End
