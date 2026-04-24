Describe 'sx_arg_rquote'
  Include ./sx.sh
  It 'encodes arguments in reverse order safely for eval'
    set -- "first" "second" "third"
    When call sx_arg_rquote reversed_args "$@"
    The status should be success
    # Verify by eval
    eval "set -- $reversed_args"
    v1=$1 v2=$2 v3=$3
    The variable v1 should equal "third"
    The variable v2 should equal "second"
    The variable v3 should equal "first"
  End
End
