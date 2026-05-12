#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_iquote'
  Include ./sx.sh

  It 'interval=1 で引数間にセパレータを挿入してクォートすること'
    When call sx_arg_iquote res "-" 1 "a" "b" "c"
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
    When call sx_arg_iquote res "-" 2 "1" "2" "3" "4" "5"
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
    When call sx_arg_iquote res "-" -2 "1" "2" "3" "4" "5"
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
    When call sx_arg_iquote res "-" -2 "1" "2" "3" "4"
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
    When call sx_arg_iquote res "-" 1
    The status should be success
    The variable res should equal ""
  End

  It '引数が1つの場合はセパレータが挿入されないこと'
    When call sx_arg_iquote res "-" 1 "only"
    The status should be success
    The variable res should equal "'only'"
  End

  It 'interval=0 の場合はエラーになること'
    When call sx_arg_iquote res "-" 0 "a" "b"
    The status should equal 64
  End

  It '特殊文字が含まれる場合でも正しくクォートされること'
    When call sx_arg_iquote res " " 1 "a'b" '"c"'
    The status should be success
    eval "set -- $res"
    The value "$1" should equal "a'b"
    The value "$2" should equal " "
    The value "$3" should equal '"c"'
  End

  It '読み取り専用変数に書き込もうとした場合にエラーになること'
    readonly ro_res_iquote="fixed"
    When call sx_arg_iquote ro_res_iquote "-" 1 "a"
    The status should equal 77
  End

  Describe 'セパレータ (:::) 形式'
    It '最小構成 (res ::: a b c) で動作すること'
      When call sx_arg_iquote res ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal ""
      The value "$3" should equal "b"
      The value "$4" should equal ""
      The value "$5" should equal "c"
    End

    It 'セパレータのみ指定 (res sep ::: a b c) で動作すること'
      When call sx_arg_iquote res "-" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "-"
      The value "$3" should equal "b"
      The value "$4" should equal "-"
      The value "$5" should equal "c"
    End

    It 'フル指定 (res sep int ::: a b c) で動作すること'
      When call sx_arg_iquote res "-" 2 ::: "a" "b" "c" "d"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "-"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
    End

    It 'データの中に ::: が含まれていても誤判定されないこと'
      When call sx_arg_iquote res "-" 1 "a" "b" ::: "c"
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
      When call sx_arg_iquote res "-" "invalid" ::: "a" "b"
      The status should equal 64
    End
  End

End
