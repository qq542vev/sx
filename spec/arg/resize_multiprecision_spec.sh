# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh disable=SC2154
# ShellSpec: Parameters内の負数・Parameters内の空文字列を使用する。
# shellcheck disable=SC2215,SC2286
# a/b/expected は参照渡しで設定する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_resize 多倍長対応'
  # Exampleごとに対象だけを読み込む。IncludeはExampleの外で宣言する。
  load_subject() {
    case "$1" in
      sx_arg_resize)
        Include ./spec/support/library.sh sx_arg_resize
        ;;
      __sx_arg_resize)
        Include ./spec/support/library.sh __sx_arg_resize
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/setup.sh

  Context '算術域を超える形状'
    Parameters
      sx_arg_resize 0
      sx_arg_resize 1
      __sx_arg_resize 0
    End

    BeforeEach 'sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR SX_SYS_NUM_MAX -- "sx_cfg_set NUM_RANGE=32"'

    It '巨大な1次元形状を分配先の個数で打ち切る'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" 'a:b:c:' 1000000000000000000000000000000 p ::: x y
      The status should be success
      The variable a should equal x
      The variable b should equal y
      The variable c should equal p
    End

    It '巨大な左パディングを多倍長で数える'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" 'a:b:' 1000000000000000000000000000000 p 2 ::: x y
      The status should be success
      The variable a should equal p
      The variable b should equal p
    End

    It '巨大な外側の軸でも内側の要素を階層化する'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" 'a:b:' 1000000000000000000000000000000:2 p ::: x y z
      The status should be success
      The variable a should equal "'x' 'y'"
      The variable b should equal "'z' 'p'"
    End

    It '軸単体が64bit内でも積の桁溢れを起こさない'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" 'a:' 9223372036854775807:2 p 2 ::: x y z
      The status should be success
      The variable a should equal "'p' 'p'"
    End

    It '巨大な既知の軸から -1 を切り上げ推論する'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" 'a:b:c:' 1000000000000000000000000000000:-1 p ::: x y
      The status should be success
      The variable a should equal "'x'"
      The variable b should equal "'y'"
      The variable c should equal "'p'"
    End

    It '空入力では巨大な既知の軸に対する推論値を0にする'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" 'a:b:' 1000000000000000000000000000000:-1 :::
      The status should be success
      The variable a should equal ''
      The variable b should equal ''
    End

    It '外側が0なら巨大な内側の軸を生成しない'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      res=old
      When call "$1" res 0:1000000000000000000000000000000 ::: x y
      The status should be success
      The variable res should equal ''
    End

    It '0の軸より内側は出力に含めない'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" 'a:b:' 2:2:0:1000000000000000000000000000000 ::: x y
      The status should be success
      The variable a should equal "'' ''"
      The variable b should equal "'' ''"
    End

    It '0の積に対する推論値は0にする'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" res -1:1000000000000000000000000000000:0 ::: x y
      The status should be success
      The variable res should equal ''
    End

    It '空バインドなら巨大な内側の軸を生成しない'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" '' 2:1000000000000000000000000000000 ::: x y
      The status should be success
    End

    It '個数付きの蓄積バインドも巨大な形状で打ち切る'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" '2res:' 1000000000000000000000000000000 p ::: x
      The status should be success
      The variable res should equal "'x' 'p'"
    End
  End

  Context '境界と従来の形状'
    It '32bitの上限で切り上げ推論の加算を桁溢れさせない'
      load_subject sx_arg_resize
      sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR SX_SYS_NUM_MAX -- 'sx_cfg_set "$@"' NUM_RANGE=32
      When call sx_arg_resize 'a:b:c:' 2147483647:-1 p ::: x y
      The status should be success
      The variable a should equal "'x'"
      The variable b should equal "'y'"
      The variable c should equal "'p'"
    End

    It '左パディングの終了後に入力へ切り替え、余分な入力は切り捨てる'
      load_subject sx_arg_resize
      When call sx_arg_resize 'a:b:' 3:2 p 2 ::: x y z
      The status should be success
      The variable a should equal "'p' 'p'"
      The variable b should equal "'p' 'x'"
    End

    It '3次元の各階層を正しくクォートする'
      load_subject sx_arg_resize
      When call sx_arg_resize 'a:b:' 2:2:2 p ::: a b c d e
      The status should be success
      eval "set -- $a"
      The value "$#" should equal 2
      The value "$1" should equal "'a' 'b'"
      The value "$2" should equal "'c' 'd'"
      eval "set -- $b"
      The value "$#" should equal 2
      The value "$1" should equal "'e' 'p'"
      The value "$2" should equal "'p' 'p'"
    End

    It '空文字列、引用符、改行を持つ入力を保持する'
      load_subject sx_arg_resize
      value="it's
ok"
      sxtest_setup expected -- 'sx_arg_quote "$@"' expected '' "$value"
      When call sx_arg_resize 'a:b:' 2:2 "$value" ::: '' "$value" x
      The status should be success
      The variable a should equal "$expected"
      eval "set -- $b"
      The value "$1" should equal x
      The value "$2" should equal "$value"
    End

    It 'セパレータ変更後も短縮形式の空形状を解釈する'
      load_subject sx_arg_resize
      sxtest_setup SX_CFG_SEP -- 'sx_cfg_set "$@"' SEP=SEP
      When call sx_arg_resize res '' SEP a b
      The status should be success
      The variable res should equal "'a' 'b'"
    End

    It '0の1次元形状では結果を初期化する'
      load_subject sx_arg_resize
      res=old
      When call sx_arg_resize res 0 ::: a b
      The status should be success
      The variable res should equal ''
    End
  End

  Context '不正な形状'
    Parameters
      '1-1'
      '--1'
      '-0'
      '-2'
      '-10'
      '01'
      '00'
      '08'
      '+1'
      '1::2'
      '1:'
      ':1'
      '-1:-1'
      '1:2-1'
      '1:00'
      '1:0x10'
      '1:1+1'
      '1: 2'
    End

    It '結果を変更せず64を返す'
      load_subject sx_arg_resize
      res=old
      When call sx_arg_resize res "$1" ::: x
      The status should equal 64
      The variable res should equal old
    End
  End

  Context '不正なフラグ'
    Parameters
      ''
      x
      -1
      2147483648
    End
    It '一時変数を漏洩させず64を返す'
      load_subject sx_arg_resize
      sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR SX_SYS_NUM_MAX -- 'sx_cfg_set "$@"' NUM_RANGE=32
      res=old
      When call sx_arg_resize res 2 p "$1" ::: x
      The status should equal 64
      The variable res should equal old
    End
  End
End
