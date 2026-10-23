# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# ShellSpec: 展開せずに渡すテスト入力を使用する。
# shellcheck disable=SC2016
Describe 'sx_str_chunk -efu 環境検証'
  Include ./spec/support/run.sh
  Include ./spec/support/library.sh sx_str_chunk

  It '正常動作'

    When run efu_run sx_str_chunk res "abcde" 2
    The status should be success
  End

  Context '周期指定'
    Parameters
      '0:-1:2'
      '-2:-1'
      '2:-1:0'
    End

    It '空チャンクと後方チャンクを含む周期を処理すること'
      When run efu_run sx_str_chunk res 'ab *?$()' "$1"
      The status should be success
    End
  End

  Context '多倍長整数'
    Before 'sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR -- "sx_cfg_set NUM_RANGE=32"'

    Parameters
      '9223372036854775808'
      '-9223372036854775808'
      '0:+1:-2'
      '2:-1:999999999999999999999999999999999'
    End

    It '巨大な長さ・回数を -efu 下で処理すること'
      When run efu_run sx_str_chunk res abcdefg "$1" 999999999999999999999999999999999
      The status should be success
      The output should equal ''
    End
  End

End
