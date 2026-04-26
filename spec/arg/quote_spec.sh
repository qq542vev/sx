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
End
