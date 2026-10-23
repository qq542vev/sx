# shellcheck disable=SC2016 # CMD内の変数は補助処理用シェルで展開する。
# shellcheck shell=sh
# ShellSpec: 間接的に呼び出すコールバック・スタブを使用する。
# shellcheck disable=SC2329

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_rfold'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_arg_rfold)
        Include ./spec/support/library.sh sx_arg_rfold
        ;;
      __sx_arg_rfold)
        Include ./spec/support/library.sh __sx_arg_rfold
        ;;
      sx_arg_fold)
        Include ./spec/support/library.sh sx_arg_fold
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/run.sh

  Describe '右から左への順序検証'
    It 'prefix (val+acc) で右畳み込みの順序を確認する'
      load_subject sx_arg_rfold
      prefix() { sxtest_run "$1" -- 'sx_var_set "$@"' "$1=${3}${2}"; }
      When call sx_arg_rfold res prefix "" a b c
      The status should be success
      The variable res should equal "abc"
    End

    It '左畳み込みとは逆順になる'
      load_subject sx_arg_fold
      prefix() { sxtest_run "$1" -- 'sx_var_set "$@"' "$1=${3}${2}"; }
      When call sx_arg_fold res prefix "" a b c
      The variable res should equal "cba"
    End
  End

  Describe '基本畳み込み: 数値の合計'
    It '初期値 0 で合計を計算する'
      load_subject sx_arg_rfold
      sum() { sxtest_run "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      When call sx_arg_rfold res sum 0 1 2 3 4 5
      The status should be success
      The variable res should equal 15
    End

    It '初期値 10 で合計を計算する'
      load_subject sx_arg_rfold
      sum() { sxtest_run "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      When call sx_arg_rfold res sum 10 1 2 3
      The status should be success
      The variable res should equal 16
    End
  End

  Describe 'スキップ: ret を unset でアキュムレータ維持'
    It '条件に合わない要素をスキップする'
      load_subject sx_arg_rfold
      sum_even() {
        case $(($3 % 2)) in 0) sxtest_run "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; esac
      }
      When call sx_arg_rfold res sum_even 0 1 2 3 4
      The status should be success
      The variable res should equal 6
    End

    It '全要素スキップすると初期値が返る'
      load_subject sx_arg_rfold
      skipall() { :; }
      When call sx_arg_rfold res skipall 42 a b c
      The status should be success
      The variable res should equal 42
    End
  End

  Describe 'コールバックエラーで即時終了'
    It 'cb が非0を返すとその時点の acc とエラーステータスを返す'
      load_subject sx_arg_rfold
      err_on_b() { case $3 in b) return 2;; esac; sxtest_run "$1" -- 'sx_var_set "$@"' "$1=$(($2 + 1))"; }
      When call sx_arg_rfold res err_on_b 0 a b c
      The status should equal 2
      The variable res should equal 1
    End

    It 'エラー発生以降の要素は処理されない'
      load_subject sx_arg_rfold
      cnt=0
      err_then_stop() {
        : $((cnt += 1))
        case $3 in b) return 2;; esac
        sxtest_run "$1" -- 'sx_var_set "$@"' "$1=$(($2 + 1))"
      }
      When call sx_arg_rfold res err_then_stop 0 a b c d e
      The status should equal 2
      The variable res should equal 3
      The variable cnt should equal 4
    End

    It '最初の要素（右端）でエラーになると初期値が返る'
      load_subject sx_arg_rfold
      always_err() { return 3; }
      When call sx_arg_rfold res always_err 99 a b c
      The status should equal 3
      The variable res should equal 99
    End
  End

  Describe '空リスト'
    It '要素がない場合、初期値がそのまま返る'
      load_subject sx_arg_rfold
      cb() { sxtest_run "$1" -- 'sx_var_set "$@"' "$1=changed"; }
      When call sx_arg_rfold res cb init
      The status should be success
      The variable res should equal "init"
    End
  End

  Describe '単一要素'
    It '1要素だけ処理する'
      load_subject sx_arg_rfold
      sum() { sxtest_run "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      When call sx_arg_rfold res sum 5 7
      The status should be success
      The variable res should equal 12
    End
  End

  Describe 'エラーケース'
    It '結果変数が読み取り専用の場合に EX_NOPERM を返す'
      load_subject sx_arg_rfold
      cb() { sxtest_run "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      readonly ro_fold=0
      When call sx_arg_rfold ro_fold cb 0 a
      The status should equal 77
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'チェックをスキップして rfold する'
      load_subject sx_arg_rfold
      sum() { sxtest_run "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      SX_CFG_SKIP_CHK=1
      When call sx_arg_rfold res sum 0 1 2 3
      The status should be success
      The variable res should equal 6
    End
  End

  Describe '内部関数 (__sx_arg_rfold)'
    It '__sx_arg_rfold が正しく動作する'
      load_subject __sx_arg_rfold
      prefix() { sxtest_run "$1" -- 'sx_var_set "$@"' "$1=${3}${2}"; }
      When call __sx_arg_rfold res prefix "" a b c
      The status should be success
      The variable res should equal "abc"
    End
  End

  Describe '再帰呼び出し'
    It 'rfold 内で rfold を呼び出しても状態が壊れない'
      load_subject sx_arg_rfold
      inner_sum() { sxtest_run "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      outer_rfold() {
        __sx_arg_rfold __sx_arg_rfold_tmp inner_sum "$2" "$3" 0
        eval "$1=\${__sx_arg_rfold_tmp}"
        unset __sx_arg_rfold_tmp
      }
      When call sx_arg_rfold res outer_rfold 0 1 2 3
      The status should be success
      The variable res should equal 6
    End
  End
End
