#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_quote'
  Include ./sx.sh

  Context '引数個数の制限なし'
    Before 'reject_quote_arg_count'

    # shellcheck disable=SC2329
    reject_quote_arg_count() {
      # 巨大な引数リストを作らず、呼び出し時の個数4を範囲外とする。
      __sx_num_is_nat0_safe() {
        case "${1-}" in 4) return 1;; esac
        return 0
      }
    }

    It '安全範囲外の個数でも空文字列と引用符を保持して復元できること'
      When call sx_arg_quote encoded_args 'a b' "c'd" ''
      The status should be success
      eval "set -- $encoded_args"
      The value "$#" should equal 3
      The value "$1" should equal 'a b'
      The value "$2" should equal "c'd"
      The value "$3" should equal ''
    End

    It '安全範囲外の個数でも分配代入できること'
      When call sx_arg_quote 'head_arg:tail_args' 'a b' "c'd" ''
      The status should be success
      The variable head_arg should equal 'a b'
      # shellcheck disable=SC2154
      eval "set -- $tail_args"
      The value "$#" should equal 2
      The value "$1" should equal "c'd"
      The value "$2" should equal ''
    End
  End

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

  Describe '分割代入'
    It '基本的な分割代入を実行すること'
      When call sx_arg_quote 'a:b:c' val1 val2 val3 val4
      The status should be success
      The variable a should equal "val1"
      The variable b should equal "val2"
      eval "set -- $c"
      The value "$1" should equal "val3"
      The value "$2" should equal "val4"
      The value "$#" should equal 2
    End

    It 'スキーマ内でのスキップをサポートすること'
      When call sx_arg_quote 'a::c' val1 val2 val3 val4
      The status should be success
      The variable a should equal "val1"
      eval "set -- $c"
      The value "$1" should equal "val3"
      The value "$2" should equal "val4"
    End

    It '引数が不足している場合でも変数を初期化すること'
      a="pre" b="pre" c="pre"
      When call sx_arg_quote 'a:b:c' val1
      The status should be success
      The variable a should equal "val1"
      The variable b should be undefined
      The variable c should equal ""
    End

    It 'スキーマがコロンで終わる場合に残りの引数を破棄すること'
      When call sx_arg_quote 'a:b:' val1 val2 val3
      The status should be success
      The variable a should equal "val1"
      The variable b should equal "val2"
    End

    It '再利用時に既存の配列変数を呼び出し側がクリーンアップすること'
      # Correctly initialize an SX array
      sx_arr_gen myarr
      sx_arr_push myarr "old"
      # 配列のクリーンアップは呼び出し側の責務
      sx_var_unset myarr
      When call sx_arg_quote 'myarr' newval
      The status should be success
      The variable myarr should equal "'newval'"
      The variable myarr_len should be undefined
      The variable myarr_0 should be undefined
    End
  End
End
