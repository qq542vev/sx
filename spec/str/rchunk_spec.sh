#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# ShellSpec の Parameters と引用文字列に関する診断を抑制する。
# shellcheck disable=SC2016,SC2215,SC2286,SC2288,SC2329

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_rchunk'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_str_rchunk.sh

  Context '基準方向と結果順'
    Parameters
      abcde 2 '' 0 "'de' 'bc' 'a'"
      abcde -2 '' 0 "'e' 'cd' 'ab'"
      abcde '' '' 0 "'e' 'd' 'c' 'b' 'a'"
      abcde +2 '' 0 "'de' 'bc' 'a'"
      abcde 2 0 0 "'abcde'"
      abcde 2 1 0 "'de' 'abc'"
      abcde -2 1 0 "'cde' 'ab'"
      abcde 2 1 2 "'de'"
      abcde -2 1 2 "'ab'"
      abcde 2 '' 1 "'de' 'bc'"
      abcde -2 '' 1 "'cd' 'ab'"
      abcdef 2 '' 3 "'ef' 'cd' 'ab'"
      abcdefg '2:-1' '' 0 "'fg' 'de' 'c' 'b' 'a'"
      abcdefg '2:-1' 2 0 "'fg' 'bcde' 'a'"
      abcdefg '-2:-1' '' 0 "'g' 'f' 'de' 'c' 'ab'"
      abc '0:1:2' '' 0 "'' 'c' 'ab' ''"
      '' '0:1' '' 0 "''"
      '' 2 '' 0 ''
      abc 9223372036854775808 '' 0 "'abc'"
      abc -9223372036854775808 '' 1 ''
      abcdefg '2:-1:9223372036854775808' '' 0 "'fg' 'bcde' 'a'"
      abcdefg '2:-1:9223372036854775808' '' 1 "'fg' 'a'"
      abcde -2 999999999999999999999999999999 0 "'e' 'cd' 'ab'"
    End

    It '符号・周期・回数・残余フラグを後方基準で処理すること'
      When call sx_str_rchunk res "$1" "$2" "$3" "$4"
      The status should be success
      The variable res should equal "$5"
    End
  End

  Context 'バインド順'
    Parameters
      2 fg de "'bc' 'a'"
      -2 g ef "'cd' 'ab'"
      '2:-1' fg de "'c' 'b' 'a'"
    End

    It '基準方向から順にバインドし残りを蓄積すること'
      When call sx_str_rchunk 'v1:v2:rest' abcdefg "$1" ''
      The status should be success
      The variable v1 should equal "$2"
      The variable v2 should equal "$3"
      The variable rest should equal "$4"
    End
  End

  It '末尾から取得しバインド枯渇で早期終了すること'
    When call sx_str_rchunk 'v1:v2:' abcdefg 2 ''
    The status should be success
    The variable v1 should equal fg
    The variable v2 should equal de
  End

  It '残余を除外して前方の予約分を取得すること'
    When call sx_str_rchunk 'v1:' abcdefg '-2:-1' 2 "2"
    The status should be success
    The variable v1 should equal c
  End

  It 'チャンク内のメタ文字と引用符を保持すること'
    When call sx_str_rchunk 'v1:v2:v3:' "a' *?$" 2 ''
    The status should be success
    The variable v1 should equal '?$'
    The variable v2 should equal ' *'
    The variable v3 should equal "a'"
  End

  Context '多倍長経路'
    Parameters
      '2:-1' "'fg' 'de' 'c' 'b' 'a'"
      '-2:-1' "'g' 'f' 'de' 'c' 'ab'"
      '0:2:-1' "'' 'fg' '' 'de' '' 'c' 'b' 'a'"
    End

    It '文字列長が範囲外でも予約分を含めて後方から格納すること'
      __sx_num_is_int_fit_dec() {
        case "${#}:${2-}:${3-}" in 3:7:20) return 1;; esac
        return 0
      }
      When call sx_str_rchunk res abcdefg "$1" 20
      The status should be success
      The variable res should equal "$2"
    End
  End

  It '検証省略時も後方を基準にすること'
    SX_CFG_SKIP_CHK=1
    When call sx_str_rchunk res abcde 2 ''
    The status should be success
    The variable res should equal "'de' 'bc' 'a'"
  End

  It '長さ省略時は末尾から1文字ずつ返すこと'
    When call sx_str_rchunk res abc
    The status should be success
    The variable res should equal "'c' 'b' 'a'"
  End

  It '文字列省略時は空の結果を返すこと'
    When call sx_str_rchunk res
    The status should be success
    The variable res should equal ''
  End

  Context '不正な長さ・回数・フラグ'
    Parameters
      '0' '' '0'
      '0:-0:+0' '' '0'
      '01' '' '0'
      '0x2' '' '0'
      '1::2' '' '0'
      '1:' '' '0'
      ':1' '' '0'
      '1:a' '' '0'
      '1:$(exit 99)' '' '0'
      '1' '01' '0'
      '1' '0x2' '0'
      '1' '+1' '0'
      '1' '-1' '0'
      '1' '' '-1'
      '1' '' 'invalid'
    End

    It '64で拒否して結果を変更しないこと'
      res=original
      When call sx_str_rchunk res abc "$1" "$2" "$3"
      The status should equal 64
      The variable res should equal original
      The stderr should equal ''
    End
  End

  It 'スキーマの省略を拒否すること'
    When call sx_str_rchunk
    The status should equal 64
    The stderr should equal ''
  End

  It '不正なスキーマを拒否すること'
    When call sx_str_rchunk 'res;other' abc 1
    The status should equal 64
    The stderr should equal ''
  End

  It 'バインド先に読み取り専用変数が含まれる場合は77を返すこと'
    readonly ro_rchunk=original
    res=original
    When call sx_str_rchunk res:ro_rchunk: abc 1
    The status should equal 77
    The variable ro_rchunk should equal original
    The variable res should equal original
  End

  It '不正な設定では78を返して結果を変更しないこと'
    SX_CFG_NUM_RANGE=invalid
    res=original
    When call sx_str_rchunk res abc 1
    The status should equal 78
    The variable res should equal original
  End

  Context '残余フラグ'
    Parameters
      '1' "'de' 'bc'"
      '2' "'de'"
    End

    It 'rchunk用のフラグで短い余り・長い余りを除外すること'
      case "$1" in
        1) flag=1 limit=;;
        2) flag=2 limit=1;;
      esac
      When call sx_str_rchunk res abcde 2 "$limit" "$flag"
      The status should be success
      The variable res should equal "$2"
    End
  End

  Context 'IFS=a での動的な数値関数呼び出し'
    with_ifs_a() { IFS=a "${@}"; }
    Before 'sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR -- "sx_cfg_set NUM_RANGE=32"'

    Parameters
      '2' "'fg' 'bcde' 'a'"
      '2147483648' "'fg' 'de' 'c' 'b' 'a'"
    End

    It '算術・多倍長の減算で残り回数を更新すること'
      When call with_ifs_a sx_str_rchunk res abcdefg '2:-1' "$1"
      The status should be success
      The variable res should equal "$2"
      The stderr should equal ''
    End
  End

End
