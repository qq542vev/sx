# shellcheck shell=sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_fold'
  Include ./sx.sh

  Describe '基本畳み込み: 数値の合計'
    It '初期値 0 で合計を計算する'
      sum() { __sx_var_set "$1=$(($2 + $3))"; }
      When call sx_arg_fold res sum 0 1 2 3 4 5
      The status should be success
      The variable res should equal 15
    End

    It '初期値 10 で合計を計算する'
      sum() { __sx_var_set "$1=$(($2 + $3))"; }
      When call sx_arg_fold res sum 10 1 2 3
      The status should be success
      The variable res should equal 16
    End
  End

  Describe '基本畳み込み: 文字列連結'
    It '文字列を連結する'
      concat() { __sx_var_set "$1=$2$3"; }
      When call sx_arg_fold res concat '' a b c
      The status should be success
      The variable res should equal "abc"
    End

    It '区切り文字付き連結'
      join_with_comma() { __sx_var_set "$1=$2,$3"; }
      When call sx_arg_fold res join_with_comma '' a b c
      The status should be success
      The variable res should equal ",a,b,c"
    End
  End

  Describe 'スキップ: ret を unset でアキュムレータ維持'
    It '条件に合わない要素をスキップする'
      sum_even() {
        case $(($3 % 2)) in 0) __sx_var_set "$1=$(($2 + $3))"; esac
      }
      When call sx_arg_fold res sum_even 0 1 2 3 4
      The status should be success
      The variable res should equal 6
    End

    It '全要素スキップすると初期値が返る'
      skipall() { :; }
      When call sx_arg_fold res skipall 42 a b c
      The status should be success
      The variable res should equal 42
    End
  End

  Describe 'コールバックエラーで即時終了'
    It 'cb が非0を返すとその時点の acc とエラーステータスを返す'
      err_on_b() { case $3 in b) return 2;; esac; __sx_var_set "$1=$(($2 + 1))"; }
      When call sx_arg_fold res err_on_b 0 a b c
      The status should equal 2
      The variable res should equal 1
    End

    It 'エラー発生以降の要素は処理されない'
      cnt=0
      err_then_stop() {
        : $((cnt += 1))
        case $3 in b) return 2;; esac
        __sx_var_set "$1=$(($2 + 1))"
      }
      When call sx_arg_fold res err_then_stop 0 a b c d e
      The status should equal 2
      The variable res should equal 1
      The variable cnt should equal 2
    End

    It '最初の要素でエラーになると初期値が返る'
      always_err() { return 3; }
      When call sx_arg_fold res always_err 99 a b c
      The status should equal 3
      The variable res should equal 99
    End
  End

  Describe '空リスト'
    It '要素がない場合、初期値がそのまま返る'
      cb() { __sx_var_set "$1=changed"; }
      When call sx_arg_fold res cb init
      The status should be success
      The variable res should equal "init"
    End
  End

  Describe '単一要素'
    It '1要素だけ処理する'
      sum() { __sx_var_set "$1=$(($2 + $3))"; }
      When call sx_arg_fold res sum 5 7
      The status should be success
      The variable res should equal 12
    End
  End

  Describe 'エラーケース'
    It '結果変数が読み取り専用の場合に EX_NOPERM を返す'
      cb() { __sx_var_set "$1=$(($2 + $3))"; }
      readonly ro_fold=0
      When call sx_arg_fold ro_fold cb 0 a
      The status should equal 77
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'チェックをスキップして fold する'
      sum() { __sx_var_set "$1=$(($2 + $3))"; }
      SX_CFG_SKIP_CHK=1
      When call sx_arg_fold res sum 0 1 2 3
      The status should be success
      The variable res should equal 6
    End
  End

  Describe '内部関数 (__sx_arg_fold)'
    It '__sx_arg_fold が正しく動作する'
      sum() { __sx_var_set "$1=$(($2 + $3))"; }
      When call __sx_arg_fold res sum 0 1 2 3
      The status should be success
      The variable res should equal 6
    End
  End

  Describe '再帰呼び出し'
    It 'fold 内で fold を呼び出しても状態が壊れない'
      inner_sum() { __sx_var_set "$1=$(($2 + $3))"; }
      outer_fold() {
        __sx_arg_fold __sx_arg_fold_tmp inner_sum "$2" "$3" 0
        eval "$1=\${__sx_arg_fold_tmp}"
        unset __sx_arg_fold_tmp
      }
      When call sx_arg_fold res outer_fold 0 1 2 3
      The status should be success
      The variable res should equal 6
    End
  End
End
