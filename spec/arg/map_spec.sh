# shellcheck shell=sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_map'
  Include ./sx.sh

  Describe 'マップ: 全要素に変換を適用'
    It '各要素を大文字に変換する'
      cb() { case $2 in a) __sx_var_set "$1=A";; b) __sx_var_set "$1=B";; c) __sx_var_set "$1=C";; esac; }
      When call sx_arg_map res cb a b c
      The status should be success
      The variable res should equal "A B C"
    End

    It '空文字列も変換対象とする'
      cb() { __sx_var_set "$1=($2)"; }
      When call sx_arg_map res cb '' foo ''
      The status should be success
      The variable res should equal "() (foo) ()"
    End
  End

  Describe 'フィルター: ret を unset でスキップ'
    It '数値のみを通す'
      filternum() { case $2 in *[!0-9]*) ;; *) __sx_var_set "$1=$2"; esac; }
      When call sx_arg_map res filternum a 42 b 7 c
      The status should be success
      The variable res should equal "42 7"
    End

    It '全てスキップすると空になる'
      skipall() { :; }
      When call sx_arg_map res skipall a b c
      The status should be success
      The variable res should equal ""
    End
  End

  Describe 'フィルター + マップ'
    It '偶数番目だけ変換する'
      even_only() { case $(($3 % 2)) in 0) sx_str_upper "$1" "$2"; esac; }
      When call sx_arg_map res even_only a b c d e
      The status should be success
      The variable res should equal "B D"
    End
  End

  Describe 'エラー回復'
    It 'cb が非0を返すと元の値をバインド、ステータスを保存'
      err_on_b() { case $2 in b) return 2;; esac; __sx_var_set "$1=$2"; }
      When call sx_arg_map res err_on_b a b c
      The status should equal 2
      The variable res should equal "a b c"
    End

    It '最初のエラーステータスが優先される'
      err_on_b_d() {
        case $2 in
          b) return 2;;
          d) return 5;;
        esac
        __sx_var_set "$1=$2"
      }
      When call sx_arg_map res err_on_b_d a b c d
      The status should equal 2
      The variable res should equal "a b c d"
    End

    It '全要素でエラーになっても元の値をバインド'
      always_err() { return 3; }
      When call sx_arg_map res always_err x y
      The status should equal 3
      The variable res should equal "x y"
    End
  End

  Describe '空リスト'
    It '引数なしで空文字列、ステータス 0'
      cb() { __sx_var_set "$1=X"; }
      When call sx_arg_map res cb
      The status should be success
      The variable res should equal ""
    End
  End

  Describe 'バインド形式'
    It 'Nname: で上限を指定できる'
      cb() { sx_str_upper "$1" "$2"; }
      When call sx_arg_map "2res:" cb a b c d
      The status should be success
      The variable res should equal "A B"
    End

    It 'v1:v2: で分配代入できる'
      cb() { sx_str_upper "$1" "$2"; }
      When call sx_arg_map "r1:r2:" cb a b c
      The status should be success
      The variable r1 should equal "A"
      The variable r2 should equal "B"
    End
  End

  Describe 'エラーケース'
    It '結果変数が読み取り専用の場合に EX_NOPERM を返す'
      cb() { __sx_var_set "$1=$2"; }
      readonly ro_map=0
      When call sx_arg_map ro_map cb a b
      The status should equal 77
    End

    It '結果変数名が無効な場合に EX_USAGE を返す'
      cb() { :; }
      When call sx_arg_map "1bad" cb a
      The status should equal 64
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'チェックをスキップしてマップする'
      cb() { __sx_var_set "$1=($2)"; }
      SX_CFG_SKIP_CHK=1
      When call sx_arg_map res cb a b c
      The status should be success
      The variable res should equal "(a) (b) (c)"
    End
  End

  Describe '内部関数 (__sx_arg_map)'
    It '__sx_arg_map が正しく動作する'
      cb() { __sx_var_set "$1=($2)"; }
      When call __sx_arg_map res cb a b c
      The status should be success
      The variable res should equal "(a) (b) (c)"
    End
  End

  Describe '再帰呼び出し'
    It 'arg_map 内で arg_map を呼び出しても状態が壊れない'
      inner_cb() { __sx_var_set "$1=($2)"; }
      outer_cb() {
        __sx_arg_map __sx_arg_map_tmp inner_cb "${2}x" "${2}y"
        eval "$1=\${__sx_arg_map_tmp}"
      }
      When call sx_arg_map res outer_cb a b
      The status should be success
      The variable res should equal "(ax) (ay) (bx) (by)"
    End
  End
End
