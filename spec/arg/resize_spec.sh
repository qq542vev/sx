#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_resize'
  Include ./sx.sh

  Describe 'Form 1 (":::" 区切り)'
    It '2D padding: 4要素を2x3=6に拡張'
      When call sx_arg_resize res 2:3 0 ::: a b c d
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It '2D truncation: 8要素を2x3=6に切り詰め'
      When call sx_arg_resize res 2:3 ::: a b c d e f g h
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It '-1 推論（割り切れる）: 6要素を2:-1でcols=3'
      When call sx_arg_resize res 2:-1 ::: a b c d e f
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "a"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It '-1 推論 + padding: 5要素を2:-1でcols=3に切り上げ'
      When call sx_arg_resize res 2:-1 0 ::: a b c d e
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $2"
      The value "$1" should equal "d"
      The value "$2" should equal "e"
      The value "$3" should equal "0"
      The value "$#" should equal 3
    End

    It '-1 推論（rows）: 6要素を-1:3でrows=2'
      When call sx_arg_resize res -1:3 ::: a b c d e f
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It '3D: 2x2x2=8にパディング'
      When call sx_arg_resize res 2:2:2 0 ::: a b c d e
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$#" should equal 2
    End

    It '3D + -1: 2x-1x2 で中間軸を推論'
      When call sx_arg_resize res 2:-1:2 0 ::: a b c d e f g
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$#" should equal 2
    End

    It '空入力からパディング'
      When call sx_arg_resize res 2:3 'x' :::
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "x"
      The value "$2" should equal "x"
      The value "$3" should equal "x"
      The value "$#" should equal 3
    End

    It 'special characters in pad value'
      When call sx_arg_resize res 2:2 "it's" ::: hello world
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "hello"
      The value "$2" should equal "world"
      The value "$#" should equal 2
    End

    It 'empty pad value'
      When call sx_arg_resize res 2:2 "" ::: a
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "a"
      The value "$2" should equal ""
      The value "$#" should equal 2
    End
  End

  Describe 'エラーケース'
    It '-1 が2つで EX_USAGE'
      When call sx_arg_resize res -1:-1 ::: a b c
      The status should equal 64
    End

    It '空のshape要素で EX_USAGE'
      When call sx_arg_resize res 2: ::: a b
      The status should equal 64
    End

    It '先頭の空要素で EX_USAGE'
      When call sx_arg_resize res :3 ::: a b c
      The status should equal 64
    End

    It '非数値で EX_USAGE'
      When call sx_arg_resize res a:b ::: x y z
      The status should equal 64
    End

    It '負数（-1以外）で EX_USAGE'
      When call sx_arg_resize res -2:3 ::: a b c
      The status should equal 64
    End

    It '結果変数が読み取り専用で EX_NOPERM'
      readonly ro_resize_var="fixed"
      When call sx_arg_resize ro_resize_var 2:3 0 ::: a b c d
      The status should equal 77
    End
  End

  Describe '分割代入（バインド形式）'
    It 'スキーマで結果を分配'
      When call sx_arg_resize 'a:b:rest' 2:2 '_' ::: x y z
      The status should be success
      The variable a should equal "'x' 'y'"
      The variable b should equal "'z' '_'"
      The variable rest should equal ""
    End
  End

  Describe 'Form 2（short form: クォートのみ）'
    It '複数の引数をクォートして格納'
      When call sx_arg_resize res hello world
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "hello"
      The value "$2" should equal "world"
      The value "$#" should equal 2
    End

    It '空の引数リストは空文字列'
      When call sx_arg_resize res
      The status should be success
      The variable res should equal ""
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'チェックをスキップしてリサイズ'
      SX_CFG_SKIP_CHK=1
      When call sx_arg_resize res 2:3 0 ::: a b c d
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End
  End

  Describe '内部関数 (__sx_arg_resize)'
    It '内部関数が正しくリサイズすること'
      When call __sx_arg_resize res 2:3 0 ::: a b c d
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End
  End

  Describe 'フラグ (SX_ARG_RESIZE_PAD_LEFT)'
    It '左パディング: 4要素を2x3=6に左側から拡張'
      When call sx_arg_resize res 2:3 '_' "$SX_ARG_RESIZE_PAD_LEFT" ::: a b c d
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      _g1=$1 _g2=$2
      eval "set -- $_g1"
      The value "$1" should equal "_"
      The value "$2" should equal "_"
      The value "$3" should equal "a"
      The value "$#" should equal 3
      eval "set -- $_g2"
      The value "$1" should equal "b"
      The value "$2" should equal "c"
      The value "$3" should equal "d"
    End

    It '左パディング + -1 推論: 5要素を2x3に左側から拡張'
      When call sx_arg_resize res 2:-1 '_' "$SX_ARG_RESIZE_PAD_LEFT" ::: a b c d e
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      _g1=$1 _g2=$2
      eval "set -- $_g1"
      The value "$1" should equal "_"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      eval "set -- $_g2"
      The value "$1" should equal "c"
      The value "$2" should equal "d"
      The value "$3" should equal "e"
    End

    It 'flag=0 で従来の右パディングと同じ動作'
      When call sx_arg_resize res 2:3 0 0 ::: a b c d
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
      eval "set -- $1"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End
  End

  Describe 'ゼロ次元（空出力 / 空グループ）'
    It '0:3 は空出力'
      When call sx_arg_resize res 0:3 0 ::: a b c
      The status should be success
      The variable res should equal ""
    End

    It '2:0:3 は空グループ×2'
      When call sx_arg_resize res 2:0:3 0 ::: a b c
      The status should be success
      eval "set -- $res"
      The value "$#" should equal 2
    End
  End
End
