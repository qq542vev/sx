#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_quote'
  Include ./sx.sh

  It '引数を安全にエンコードし、eval で復元できること'
    set -- "hello world" "it's me" 'back\slash' '"double quotes"'
    When call sx_arg_quote encoded_args "$@"
    The status should be success
    
    # Verify by eval
    eval "set -- $encoded_args"
    res1=$1 res2=$2 res3=$3 res4=$4
    The variable res1 should equal "hello world"
    The variable res2 should equal "it's me"
    The variable res3 should equal 'back\slash'
    The variable res4 should equal '"double quotes"'
  End

  It '空の引数リストを処理できること'
    When call sx_arg_quote encoded_args
    The status should be success
    The variable encoded_args should equal ""
  End

  It '空文字列の引数を保持できること'
    When call sx_arg_quote encoded_args "" "val" ""
    The status should be success
    eval "set -- $encoded_args"
    res1=$1 res2=$2 res3=$3 res_cnt=$#
    The variable res1 should equal ""
    The variable res2 should equal "val"
    The variable res3 should equal ""
    The variable res_cnt should equal 3
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_quote="fixed"
    When call sx_arg_quote ro_res_quote "a"
    The status should equal 77
  End

  Describe 'Destructuring assignment'
    It 'performs basic destructuring'
      When call sx_arg_quote 'a:b:c' val1 val2 val3 val4
      The status should be success
      The variable a should equal "val1"
      The variable b should equal "val2"
      eval "set -- $c"
      The value "$1" should equal "val3"
      The value "$2" should equal "val4"
      The value "$#" should equal 2
    End

    It 'supports skips in schema'
      When call sx_arg_quote 'a::c' val1 val2 val3 val4
      The status should be success
      The variable a should equal "val1"
      eval "set -- $c"
      The value "$1" should equal "val3"
      The value "$2" should equal "val4"
    End

    It 'initializes variables even if arguments are insufficient'
      a="pre" b="pre" c="pre"
      When call sx_arg_quote 'a:b:c' val1
      The status should be success
      The variable a should equal "val1"
      The variable b should be undefined
      The variable c should equal ""
    End

    It 'discards remaining arguments if schema ends with colon'
      When call sx_arg_quote 'a:b:' val1 val2 val3
      The status should be success
      The variable a should equal "val1"
      The variable b should equal "val2"
    End

    It 'cleans up existing array variables when reused'
      # Correctly initialize an SX array
      sx_arr_gen myarr
      sx_arr_push myarr "old"
      When call sx_arg_quote 'myarr' newval
      The status should be success
      The variable myarr should equal "'newval'"
      The variable myarr_len should be undefined
      The variable myarr_0 should be undefined
    End
  End
End

Describe 'sx_arg_rquote'
  Include ./sx.sh

  It '引数を逆順で安全にエンコードし、eval で復元できること'
    set -- "first" "second" "third"
    When call sx_arg_rquote reversed_args "$@"
    The status should be success
    
    # Verify by eval
    eval "set -- $reversed_args"
    res1=$1 res2=$2 res3=$3
    The variable res1 should equal "third"
    The variable res2 should equal "second"
    The variable res3 should equal "first"
  End

  It '単一の引数を処理できること'
    When call sx_arg_rquote reversed_args "only"
    The status should be success
    eval "set -- $reversed_args"
    res1=$1 res_cnt=$#
    The variable res1 should equal "only"
    The variable res_cnt should equal 1
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
  readonly ro_res_rquote="fixed"
  When call sx_arg_rquote ro_res_rquote "a"
  The status should equal 77
  End

  Describe 'Destructuring assignment'
  It 'performs reversed destructuring'
    When call sx_arg_rquote 'a:b:c' val1 val2 val3 val4
    The status should be success
    The variable a should equal "val4"
    The variable b should equal "val3"
    eval "set -- $c"
    The value "$1" should equal "val2"
    The value "$2" should equal "val1"
    The value "$#" should equal 2
  End

  It 'supports skips in reversed schema'
    When call sx_arg_rquote 'a::c' val1 val2 val3 val4
    The status should be success
    The variable a should equal "val4"
    eval "set -- $c"
    The value "$1" should equal "val2"
    The value "$2" should equal "val1"
  End
  End
  End

