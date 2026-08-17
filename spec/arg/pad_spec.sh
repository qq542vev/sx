#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_pad'
  Include ./sx.sh

  Describe 'Form 1 (":::" 区切り)'
    It '右パディング: 3要素を5に拡張'
      When call sx_arg_pad res 5 '_' ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$4" should equal "_"
      The value "$5" should equal "_"
      The value "$#" should equal 5
    End

    It '左パディング: 3要素を-5に拡張'
      When call sx_arg_pad res -5 '_' ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "_"
      The value "$2" should equal "_"
      The value "$3" should equal "a"
      The value "$4" should equal "b"
      The value "$5" should equal "c"
      The value "$#" should equal 5
    End

    It 'パディング不要: count >= |length| ならそのまま'
      When call sx_arg_pad res 3 '_' ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It '切り詰めなし: count > |length| でもそのまま'
      When call sx_arg_pad res 2 '_' ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It '空入力からの右パディング'
      When call sx_arg_pad res 3 'x' :::
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "x"
      The value "$2" should equal "x"
      The value "$3" should equal "x"
      The value "$#" should equal 3
    End

    It '空入力からの左パディング'
      When call sx_arg_pad res -3 'x' :::
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "x"
      The value "$2" should equal "x"
      The value "$3" should equal "x"
      The value "$#" should equal 3
    End

    It '長さ0の場合は入力をそのまま返す'
      When call sx_arg_pad res 0 '_' ::: a b
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$#" should equal 2
    End

    It '長さ0・空入力の場合は空文字列'
      When call sx_arg_pad res 0 '_' :::
      The status should be success
      The variable res should equal ""
    End

    It '分割代入: スキーマで結果を分配'
      When call sx_arg_pad 'a:b:rest' 3 '_' ::: x y
      The status should be success
      The variable a should equal "x"
      The variable b should equal "y"
      eval "set -- $rest"
      The value "$1" should equal "_"
      The value "$#" should equal 1
    End

    It '特殊文字を含む値'
      When call sx_arg_pad res 3 "it's" ::: "hello" "world"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "hello"
      The value "$2" should equal "world"
      The value "$3" should equal "it's"
      The value "$#" should equal 3
    End

    It '空文字列のパディング値'
      When call sx_arg_pad res 3 "" ::: a
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal ""
      The value "$3" should equal ""
      The value "$#" should equal 3
    End

    It '長さが無効な場合 EX_USAGE を返す'
      When call sx_arg_pad res "abc" '_' ::: a
      The status should equal 64
    End

    It '結果変数が読み取り専用の場合 EX_NOPERM を返す'
      readonly ro_res_pad="fixed"
      When call sx_arg_pad ro_res_pad 3 '_' ::: a
      The status should equal 77
    End
  End

  Describe 'Form 2 (short form: クォートのみ)'
    It '複数の引数をクォートして格納すること'
      When call sx_arg_pad res hello world
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "hello"
      The value "$2" should equal "world"
      The value "$#" should equal 2
    End

    It '空の引数リストは空文字列を格納すること'
      When call sx_arg_pad res
      The status should be success
      The variable res should equal ""
    End

    It '特殊文字を含む引数をクォートすること'
      When call sx_arg_pad res "it's" 'a b'
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "it's"
      The value "$2" should equal "a b"
      The value "$#" should equal 2
    End

    It '分割代入で結果を分配すること'
      When call sx_arg_pad 'a:b:rest' hello world
      The status should be success
      The variable a should equal "hello"
      The variable b should equal "world"
      The variable rest should equal ""
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'チェックをスキップしてパディング'
      SX_CFG_SKIP_CHK=1
      When call sx_arg_pad res 4 '_' ::: a
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "_"
      The value "$3" should equal "_"
      The value "$4" should equal "_"
    End
  End

  Describe 'コールバックモード (CB)'
    It '右パディング: cbで動的に値を生成'
      cb() { __sx_var_set "${1}=($3)"; }
      When call sx_arg_pad res 5 cb "$SX_ARG_PAD_CB" ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$4" should equal "(1)"
      The value "$5" should equal "(2)"
      The value "$#" should equal 5
    End
    
    It '左パディング: cbで動的に値を生成'
      cb() { __sx_var_set "${1}=($3)"; }
      When call sx_arg_pad res -5 cb "$SX_ARG_PAD_CB" ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(1)"
      The value "$2" should equal "(2)"
      The value "$3" should equal "a"
      The value "$4" should equal "b"
      The value "$5" should equal "c"
      The value "$#" should equal 5
    End

    It 'CB引数 (idx, cnt, skip) が正しいこと'
      cb() { __sx_var_set "${1}=($2:$3:$4)"; }
      When call sx_arg_pad res 5 cb "$SX_ARG_PAD_CB" ::: x y z
      The status should be success
      eval "set -- $res"
      The value "$4" should equal "(4:1:0)"
      The value "$5" should equal "(5:2:0)"
    End
    
    It '左パディングでCB引数 (idx, cnt, skip) が正しいこと'
      cb() { __sx_var_set "${1}=($2:$3:$4)"; }
      When call sx_arg_pad res -5 cb "$SX_ARG_PAD_CB" ::: x y z
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(1:1:0)"
      The value "$2" should equal "(2:2:0)"
    End

    It 'skip: ret unsetでスロットが飛ばされる'
      cb() {
        case "${3}" in 1|3) __sx_var_set "${1}=x";; *) unset "${1}";; esac
      }
      When call sx_arg_pad res 6 cb "$SX_ARG_PAD_CB" ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$4" should equal "x"
      The value "$5" should equal "x"
      The value "$#" should equal 5
    End

    It 'skip+idx不変: skip時idxが変化しないこと'
      cb() {
        case "${3}" in 1) unset "${1}";; *) __sx_var_set "${1}=($2:$3)";; esac
      }
      When call sx_arg_pad res -6 cb "$SX_ARG_PAD_CB" ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(1:2)"
      The value "$2" should equal "(2:3)"
      The value "$#" should equal 5
    End

    It '連続skipでskipが累積すること'
      cb() { unset "${1}"; }
      When call sx_arg_pad res 5 cb "$SX_ARG_PAD_CB" ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It '中断: cbが非0を返すと処理を中断'
      cb() {
        __sx_var_set "${1}=x"
        [ "$3" -lt 2 ]
      }
      When call sx_arg_pad res 5 cb "$SX_ARG_PAD_CB" ::: a b c
      The status should be failure
      eval "set -- $res"
      The value "$#" should equal 4
      The value "$4" should equal "x"
    End

    It 'パディング不要: len <= arg countならcb呼ばれない'
      cb_called=0
      cb() { : $((cb_called += 1)); __sx_var_set "${1}=x"; }
      When call sx_arg_pad res 3 cb "$SX_ARG_PAD_CB" ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 3
      The variable cb_called should equal 0
    End

    It '空入力からの右パディング'
      cb() { __sx_var_set "${1}=($3)"; }
      When call sx_arg_pad res 3 cb "$SX_ARG_PAD_CB" :::
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(1)"
      The value "$2" should equal "(2)"
      The value "$3" should equal "(3)"
      The value "$#" should equal 3
    End
  End

  Describe 'コールバックモード - 拡張テスト'
    It '左パディング: パディング数 > 2 でも全て正しくバインドされる'
      cb() { __sx_var_set "${1}=($3)"; }
      When call sx_arg_pad res -5 cb "$SX_ARG_PAD_CB" :::
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(1)"
      The value "$2" should equal "(2)"
      The value "$3" should equal "(3)"
      The value "$4" should equal "(4)"
      The value "$5" should equal "(5)"
      The value "$#" should equal 5
    End
    
    It '右パディング: 元の値が10個以上でも正しく動作'
      cb() { __sx_var_set "${1}=($3)"; }
      When call sx_arg_pad res 12 cb "$SX_ARG_PAD_CB" ::: 0 1 2 3 4 5 6 7 8 9 A B
      The status should be success
      eval "set -- $res"
      The value "$1"   should equal "0"
      The value "${10}" should equal "9"
      The value "${11}" should equal "A"
      The value "${12}" should equal "B"
      The value "$#"   should equal 12
    End
    
    It '左パディング: 元の値が10個以上でも正しく動作'
      cb() { __sx_var_set "${1}=($3)"; }
      When call sx_arg_pad res -15 cb "$SX_ARG_PAD_CB" ::: 0 1 2 3 4 5 6 7 8 9 A B
      The status should be success
      eval "set -- $res"
      The value "$1"   should equal "(1)"
      The value "$2"   should equal "(2)"
      The value "$3"   should equal "(3)"
      The value "$4"   should equal "0"
      The value "${15}" should equal "B"
      The value "$#"   should equal 15
    End
    
    It '右パディング: パディング数 > 2 でも全て正しくバインドされる'
      cb() { __sx_var_set "${1}=($3)"; }
      When call sx_arg_pad res 5 cb "$SX_ARG_PAD_CB" :::
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "(1)"
      The value "$2" should equal "(2)"
      The value "$3" should equal "(3)"
      The value "$4" should equal "(4)"
      The value "$5" should equal "(5)"
      The value "$#" should equal 5
    End

    It '左パディング+skip混在+元の値多数でidx/skipが正しい'
      cb() {
        case "${3}" in 1|3|5) unset "${1}";; *) __sx_var_set "${1}=($2:$3:$4)";; esac
      }
      When call sx_arg_pad res -14 cb "$SX_ARG_PAD_CB" ::: a b c d e f g
      The status should be success
      eval "set -- $res"
      The value "$1"  should equal "(1:2:1)"
      The value "$2"  should equal "(2:4:2)"
      The value "$3"  should equal "(3:6:3)"
      The value "$4"  should equal "(4:7:3)"
      The value "$5"  should equal "a"
      The value "${11}" should equal "g"
      The value "$#"  should equal 11
    End

    It '右パディング+CB: 元値10個以上+実パディング'
      cb() { __sx_var_set "${1}=($3)"; }
      When call sx_arg_pad res 13 cb "$SX_ARG_PAD_CB" ::: 0 1 2 3 4 5 6 7 8 9 A B
      The status should be success
      eval "set -- $res"
      The value "$1"   should equal "0"
      The value "${10}" should equal "9"
      The value "${11}" should equal "A"
      The value "${12}" should equal "B"
      The value "${13}" should equal "(1)"
      The value "$#"   should equal 13
    End
    
    It '左パディング+CB: cbが非0を返すと中断'
      cb() {
        __sx_var_set "${1}=x"
        [ "$3" -lt 2 ]
      }
      When call sx_arg_pad res -5 cb "$SX_ARG_PAD_CB" ::: a b c
      The status should be failure
      eval "set -- $res"
      The value "$#" should equal 4
      The value "$1" should equal "x"
    End

    It '右パディング+skip+元値あり: idx/skipが正しい'
      cb() {
        case "${3}" in 1) unset "${1}";; *) __sx_var_set "${1}=($2:$3)";; esac
      }
      When call sx_arg_pad res 6 cb "$SX_ARG_PAD_CB" ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$4" should equal "(4:2)"
      The value "$5" should equal "(5:3)"
      The value "$#" should equal 5
    End

    It '全skip+右パディング: 元値のみ残る'
      cb() { unset "${1}"; }
      When call sx_arg_pad res 8 cb "$SX_ARG_PAD_CB" ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It 'padding数1のCB呼出: idx/cnt/skipが正しい'
      cb() { __sx_var_set "${1}=($2:$3:$4)"; }
      When call sx_arg_pad res 4 cb "$SX_ARG_PAD_CB" ::: x y z
      The status should be success
      eval "set -- $res"
      The value "$4" should equal "(4:1:0)"
      The value "$#" should equal 4
    End
  End

  Describe '内部関数 (__sx_arg_pad)'
    It '内部関数が正しくパディングすること'
      When call __sx_arg_pad res 4 '_' ::: a b
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "_"
      The value "$4" should equal "_"
    End
  End
End
