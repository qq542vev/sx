# shellcheck shell=sh

Describe 'arg 関数の第一引数 bind'
  Include ./sx.sh

  Context 'bind の省略'
    Parameters
      sx_arg_find
      sx_arg_rfind
      sx_arg_isep
      sx_arg_pad
      sx_arg_resize
      sx_arg_map
      sx_arg_quote
      sx_arg_rquote
    End

    It '引数なしは使用法エラーにする'
      When call "$1"
      The status should equal 64
    End
  End

  Context '空 bind の明示'
    Parameters
      sx_arg_find 1
      sx_arg_rfind 1
      sx_arg_isep 0
      sx_arg_pad 0
      sx_arg_resize 0
      sx_arg_map 0
      sx_arg_quote 0
      sx_arg_rquote 0
    End

    It '空文字列を省略と区別し各関数の終了状態を返す'
      When call "$1" ''
      The status should equal "$2"
    End
  End
End
