#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# ShellSpec: Parameters内の負数・間接的に呼び出すコールバック・スタブを使用する。
# shellcheck disable=SC2215,SC2329

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_isep 多倍長対応'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_str_isep)
        sxtest_load ./build/modules/sx_str_isep.sh
        ;;
      __sx_str_isep)
        sxtest_load ./build/modules/__sx_str_isep.sh
        ;;
      *) return 64;;
    esac
  }
  Include ./spec/support/run.sh

  It '巨大な間隔 999999999999999999999999999999 では内部境界のパターンを生成しないこと'
    load_subject sx_str_isep
    __sx_str_qm() { return 64; }
    When call sx_str_isep res:cnt abc - 999999999999999999999999999999 '' 6
    The status should be success
    The variable res should equal "-abc"
    The variable cnt should equal "'1'"
  End

  It '巨大な間隔 -999999999999999999999999999999 では内部境界のパターンを生成しないこと'
    load_subject sx_str_isep
    __sx_str_qm() { return 64; }
    When call sx_str_isep res:cnt abc - -999999999999999999999999999999 '' 6
    The status should be success
    The variable res should equal "abc-"
    The variable cnt should equal "'1'"
  End

  It '巨大な間隔 -9223372036854775808 では内部境界のパターンを生成しないこと'
    load_subject sx_str_isep
    __sx_str_qm() { return 64; }
    When call sx_str_isep res:cnt abc - -9223372036854775808 '' 6
    The status should be success
    The variable res should equal "abc-"
    The variable cnt should equal "'1'"
  End

  It '巨大な上限でも両端と内部境界を処理できること 2'
    load_subject sx_str_isep
    When call sx_str_isep res:cnt abcdef - 2 999999999999999999999999999999 6
    The status should be success
    The variable res should equal "-ab-cd-ef-"
    The variable cnt should equal "'4'"
  End

  It '巨大な上限でも両端と内部境界を処理できること -2'
    load_subject sx_str_isep
    When call sx_str_isep res:cnt abcdef - -2 999999999999999999999999999999 6
    The status should be success
    The variable res should equal "-ab-cd-ef-"
    The variable cnt should equal "'4'"
  End

  It '多倍長経路でも非整除の反対端には挿入しないこと 2'
    load_subject sx_str_isep
    When call sx_str_isep res:cnt abcde - 2 999999999999999999999999999999 6
    The status should be success
    The variable res should equal "-ab-cd-e"
    The variable cnt should equal "'3'"
  End

  It '多倍長経路でも非整除の反対端には挿入しないこと -2'
    load_subject sx_str_isep
    When call sx_str_isep res:cnt abcde - -2 999999999999999999999999999999 6
    The status should be success
    The variable res should equal "a-bc-de-"
    The variable cnt should equal "'3'"
  End

  It '上限0ではパターンもコールバックも呼ばないこと 2'
    load_subject sx_str_isep
    __sx_str_qm() { return 64; }
    cb() { return 77; }
    When call sx_str_isep res:cnt abcdef cb 2 0 7
    The status should be success
    The variable res should equal abcdef
    The variable cnt should equal "'0'"
  End

  It '上限0ではパターンもコールバックも呼ばないこと -2'
    load_subject sx_str_isep
    __sx_str_qm() { return 64; }
    cb() { return 77; }
    When call sx_str_isep res:cnt abcdef cb -2 0 7
    The status should be success
    The variable res should equal abcdef
    The variable cnt should equal "'0'"
  End

  It '多倍長経路で再入呼び出し後もコールバックの文脈と回数を保持すること 2'
    load_subject sx_str_isep
    inner() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=-"; }
    cb() {
      sx_str_isep nested: abc inner 1 '' 1
      sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=<${2}:${3}:${4}>"
    }
    When call sx_str_isep res:cnt abcdef cb 2 999999999999999999999999999999 7
    The status should be success
    The variable res should equal "<:abcdef:1>ab<ab:cdef:2>cd<abcd:ef:3>ef<abcdef::4>"
    The variable cnt should equal "'4'"
  End

  It '多倍長経路で再入呼び出し後もコールバックの文脈と回数を保持すること -2'
    load_subject sx_str_isep
    inner() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=-"; }
    cb() {
      sx_str_isep nested: abc inner 1 '' 1
      sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=<${2}:${3}:${4}>"
    }
    When call sx_str_isep res:cnt abcdef cb -2 999999999999999999999999999999 7
    The status should be success
    The variable res should equal "<:abcdef:4>ab<ab:cdef:3>cd<abcd:ef:2>ef<abcdef::1>"
    The variable cnt should equal "'4'"
  End

  It '多倍長経路で非0終了の値を破棄すること 2 回数1'
    load_subject sx_str_isep
    cb() {
      sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=-"
      case "${4}" in 1) return 77;; esac
    }
    When call sx_str_isep res:cnt abcdef cb 2 999999999999999999999999999999 7
    The status should equal 77
    The variable res should equal "abcdef"
    The variable cnt should equal "'0'"
  End

  It '多倍長経路で非0終了の値を破棄すること 2 回数2'
    load_subject sx_str_isep
    cb() {
      sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=-"
      case "${4}" in 2) return 77;; esac
    }
    When call sx_str_isep res:cnt abcdef cb 2 999999999999999999999999999999 7
    The status should equal 77
    The variable res should equal "-abcdef"
    The variable cnt should equal "'1'"
  End

  It '多倍長経路で非0終了の値を破棄すること 2 回数4'
    load_subject sx_str_isep
    cb() {
      sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=-"
      case "${4}" in 4) return 77;; esac
    }
    When call sx_str_isep res:cnt abcdef cb 2 999999999999999999999999999999 7
    The status should equal 77
    The variable res should equal "-ab-cd-ef"
    The variable cnt should equal "'3'"
  End

  It '多倍長経路で非0終了の値を破棄すること -2 回数1'
    load_subject sx_str_isep
    cb() {
      sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=-"
      case "${4}" in 1) return 77;; esac
    }
    When call sx_str_isep res:cnt abcdef cb -2 999999999999999999999999999999 7
    The status should equal 77
    The variable res should equal "abcdef"
    The variable cnt should equal "'0'"
  End

  It '多倍長経路で非0終了の値を破棄すること -2 回数2'
    load_subject sx_str_isep
    cb() {
      sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=-"
      case "${4}" in 2) return 77;; esac
    }
    When call sx_str_isep res:cnt abcdef cb -2 999999999999999999999999999999 7
    The status should equal 77
    The variable res should equal "abcdef-"
    The variable cnt should equal "'1'"
  End

  It '多倍長経路で非0終了の値を破棄すること -2 回数4'
    load_subject sx_str_isep
    cb() {
      sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=-"
      case "${4}" in 4) return 77;; esac
    }
    When call sx_str_isep res:cnt abcdef cb -2 999999999999999999999999999999 7
    The status should equal 77
    The variable res should equal "ab-cd-ef-"
    The variable cnt should equal "'3'"
  End

  It '不正な間隔 0 を拒否すること'
    load_subject sx_str_isep
    When call sx_str_isep res: abc - 0
    The status should equal 64
  End

  It '不正な間隔 +0 を拒否すること'
    load_subject sx_str_isep
    When call sx_str_isep res: abc - +0
    The status should equal 64
  End

  It '不正な間隔 -0 を拒否すること'
    load_subject sx_str_isep
    When call sx_str_isep res: abc - -0
    The status should equal 64
  End

  It '不正な間隔 01 を拒否すること'
    load_subject sx_str_isep
    When call sx_str_isep res: abc - 01
    The status should equal 64
  End

  It '不正な間隔 0x10 を拒否すること'
    load_subject sx_str_isep
    When call sx_str_isep res: abc - 0x10
    The status should equal 64
  End

  It '不正な間隔 abc を拒否すること'
    load_subject sx_str_isep
    When call sx_str_isep res: abc - abc
    The status should equal 64
  End

  It '不正な上限 -1 を拒否すること'
    load_subject sx_str_isep
    When call sx_str_isep res: abc - 1 -1
    The status should equal 64
  End

  It '不正な上限 01 を拒否すること'
    load_subject sx_str_isep
    When call sx_str_isep res: abc - 1 01
    The status should equal 64
  End

  It '不正な上限 0x10 を拒否すること'
    load_subject sx_str_isep
    When call sx_str_isep res: abc - 1 0x10
    The status should equal 64
  End

  It '空文字列の同一境界を多倍長経路で二重挿入しないこと 1'
    load_subject sx_str_isep
    When call sx_str_isep res:cnt '' - 1 999999999999999999999999999999 6
    The status should be success
    The variable res should equal '-'
    The variable cnt should equal "'1'"
  End

  It '空文字列の同一境界を多倍長経路で二重挿入しないこと -1'
    load_subject sx_str_isep
    When call sx_str_isep res:cnt '' - -1 999999999999999999999999999999 6
    The status should be success
    The variable res should equal '-'
    The variable cnt should equal "'1'"
  End

  Context '短い文字列で多倍長経路の有限上限・省略上限を検証'
    Parameters
      2 2 6 '-ab-cdef' "'2'"
      -2 2 6 'abcd-ef-' "'2'"
      1 '' 6 '-a-b-c-d-e-f-' "'7'"
      -1 '' 6 '-a-b-c-d-e-f-' "'7'"
    End

    It '経路を多倍長側に固定しても上限を守ること'
      load_subject sx_str_isep
      __sx_num_is_int_fit_dec() {
        case "${#}:${2-}" in 3:6) return 1;; esac
        return 0
      }
      __sx_num_add_arith() { return 64; }
      When call sx_str_isep res:cnt abcdef - "$1" "$2" "$3"
      The status should be success
      The variable res should equal "$4"
      The variable cnt should equal "$5"
    End
  End

  Context '8bit範囲の最大文字列長の前後で上限省略を検証'
    Parameters
      126 127 6
      127 128 6
      128 129 6
      126 127 7
      127 128 7
      128 129 7
    End

    It '両端を含めて文字列長+1回挿入できること'
      load_subject __sx_str_isep
      str=
      sxtest_run str -- 'sx_str_rep "$@"' str a "$1"
      sxtest_run expected -- 'sx_str_rep "$@"' expected a- "$1"
      expected="-${expected}"
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR SX_SYS_NUM_MAX -- '__sx_cfg_set "$@"' NUM_RANGE=8
      cb() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=-"; }
      case "$3" in 6) sep=-;; 7) sep=cb;; esac
      When call __sx_str_isep res:cnt "$str" "$sep" 1 '' "$3"
      The status should be success
      The variable res should equal "$expected"
      The variable cnt should equal "'$2'"
    End
  End

  It '元文字列長に安全範囲検査を適用しないこと'
    load_subject sx_str_isep
    __sx_num_is_nat0_safe() {
      case "${1-}" in 3) return 1;; esac
      return 0
    }
    When call sx_str_isep res:cnt abc -
    The status should be success
    The variable res should equal a-b-c
    The variable cnt should equal "'2'"
  End
End
