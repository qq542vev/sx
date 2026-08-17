# shellcheck shell=sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_each'
  Include ./sx.sh

  Describe '基本: 各要素に副作用を適用'
    It '各要素を別の変数に追記する'
      result=
      cb() { result="${result}($1)"; }
      When call sx_arg_each cb a b c
      The status should be success
      The variable result should equal "(a)(b)(c)"
    End

    It '空文字列も処理対象とする'
      result=
      cb() { result="${result}($1)"; }
      When call sx_arg_each cb '' foo ''
      The status should be success
      The variable result should equal "()(foo)()"
    End
  End

  Describe 'インデックス'
    It 'インデックスが 1-based で渡る'
      result=
      cb() { result="${result}$2:"; }
      When call sx_arg_each cb a b c
      The status should be success
      The variable result should equal "1:2:3:"
    End
  End

  Describe '空リスト'
    It '引数なしでコールバックは呼ばれない'
      called=0
      cb() { : $((called += 1)); }
      When call sx_arg_each cb
      The status should be success
      The variable called should equal 0
    End
  End

  Describe 'エラー中断'
    It 'cb が非0を返すと即座に中断する'
      result=
      cb() {
        case $1 in
          b) return 2;;
          *) result="${result}($1)";;
        esac
      }
      When call sx_arg_each cb a b c d
      The status should equal 2
      The variable result should equal "(a)"
    End

    It '最初の要素のエラーが即座に返る'
      always_err() { return 3; }
      When call sx_arg_each always_err x y
      The status should equal 3
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'チェックをスキップして each する'
      result=
      cb() { result="${result}($1)"; }
      SX_CFG_SKIP_CHK=1
      When call sx_arg_each cb a b c
      The status should be success
      The variable result should equal "(a)(b)(c)"
    End
  End

  Describe '内部関数 (__sx_arg_each)'
    It '__sx_arg_each が正しく動作する'
      result=
      cb() { result="${result}($1)"; }
      When call __sx_arg_each cb a b c
      The status should be success
      The variable result should equal "(a)(b)(c)"
    End
  End

  Describe '再帰呼び出し'
    It 'each 内で each を呼び出しても状態が壊れない'
      result=
      inner_cb() { :; }
      outer_cb() {
        __sx_arg_each inner_cb "${1}x" "${1}y"
        result="${result}[$1]"
      }
      When call sx_arg_each outer_cb a b
      The status should be success
      The variable result should equal "[a][b]"
    End
  End
End
