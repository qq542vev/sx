# shellcheck shell=sh
# ShellSpec の Parameters 内の負数をコマンドとして解釈する診断を抑制する。
# shellcheck disable=SC2215

Describe 'sx_str_rchunk -efu 環境検証'
  Include ./spec/support/prepare.sh
  Include ./spec/support/library.sh sx_str_rchunk

  Context '後方基準'
    Parameters
      2 '' 0
      -2 '' 0
      '0:2:-1' '' 0
      '-2:-1' 2 2
      '2:-1:9223372036854775808' '' 1
      -2 999999999999999999999999999999 0
    End

    It '後方基準の分割を外部コマンドなしで処理すること'
      When run efu_run sx_str_rchunk res abcdefg "$1" "$2" "$3"
      The status should be success
      The output should equal ''
    End
  End

  Context '周期指定と巨大な数値'
    Before 'sx_test_setup sx_cfg_set NUM_RANGE=32'

    Parameters
      '0:-1:2' ''
      '-2:-1' '2'
      '9223372036854775808' ''
      '-9223372036854775808' ''
      '2:-1:999999999999999999999999999999999' '999999999999999999999999999999999'
    End

    It '空チャンク・前方予約・多倍長数値を扱えること'
      # メタ文字を含むデータは展開せず渡す。
      # shellcheck disable=SC2016
      When run efu_run sx_str_rchunk res 'ab *?$()' "$1" "$2"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '引数省略を64で拒否すること'
    When run efu_run sx_str_rchunk
    The status should equal 64
    The stderr should equal ''
  End

  It '不正な周期の検証後にも作業変数を残さないこと'
    reject_rchunk() {
      sx_str_rchunk res abc '1:bad' && return 1
      check_no_leak
    }
    When run efu_run reject_rchunk
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

End
