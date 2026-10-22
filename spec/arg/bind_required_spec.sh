# shellcheck shell=sh

Describe 'arg 関数の第一引数 bind'
  # Exampleごとに対象だけを読み込む。IncludeはExampleの外で宣言する。
  load_subject() {
    case "$1" in
      sx_arg_find)
        Include ./spec/support/library.sh sx_arg_find
        ;;
      sx_arg_rfind)
        Include ./spec/support/library.sh sx_arg_rfind
        ;;
      sx_arg_isep)
        Include ./spec/support/library.sh sx_arg_isep
        ;;
      sx_arg_pad)
        Include ./spec/support/library.sh sx_arg_pad
        ;;
      sx_arg_resize)
        Include ./spec/support/library.sh sx_arg_resize
        ;;
      sx_arg_map)
        Include ./spec/support/library.sh sx_arg_map
        ;;
      sx_arg_quote)
        Include ./spec/support/library.sh sx_arg_quote
        ;;
      sx_arg_rquote)
        Include ./spec/support/library.sh sx_arg_rquote
        ;;
      *) return 64;;
    esac
  }

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
      load_subject "$1"
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
      load_subject "$1"
      When call "$1" ''
      The status should equal "$2"
    End
  End
End
