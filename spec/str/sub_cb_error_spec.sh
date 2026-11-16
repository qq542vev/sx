#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# ShellSpec: 参照渡しで設定する変数・スタブを使用する。
# shellcheck disable=SC2154,SC2215,SC2286,SC2329

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_sub __sx_num_add1_arith 失敗時のエラーハンドリング'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_str_sub) sxtest_load ./build/modules/sx_str_sub.sh ;;
      *) return 64 ;;
    esac
  }
  Include ./spec/support/run.sh

  cb_replace() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=X"; }

  Context '__sx_num_add1_arith が失敗し arith 経路が強制される場合'
    Parameters
      '+2' a 0 XbXba 2
    End

    It '致命的エラーにならずエラーを返すこと'
      load_subject sx_str_sub
      __sx_num_is_int_fit_dec() {
        return 0
      }
      __sx_num_add1_arith() { return 64; }
      When call sx_str_sub res:cnt ababa a cb_replace '+2' 2
      The status should not equal 0
    End
  End
End
