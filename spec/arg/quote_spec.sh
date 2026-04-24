Describe 'sx_arg_quote'
  Include ./sx.sh
  It 'encodes arguments safely for eval'
    set -- "hello world" "it's me" 'back\slash' '"double quotes"'
    When call sx_arg_quote encoded_args "$@"
    The status should be success
    # Verify by eval
    eval "set -- $encoded_args"
    v1=$1 v2=$2 v3=$3 v4=$4
    The variable v1 should equal "hello world"
    The variable v2 should equal "it's me"
    The variable v3 should equal 'back\slash'
    The variable v4 should equal '"double quotes"'
  End
End
