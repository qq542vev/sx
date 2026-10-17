# shellcheck shell=sh

Describe 'sx_uri_enc -efu 環境検証'
  Include ./sx.sh

  Context '公開・内部・検証省略'
    Parameters
      sx_uri_enc 0
      sx_uri_enc 1
      __sx_uri_enc 0
    End

    It '入力省略を -efu 下で処理できる'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" res
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End

    It '保持文字だけの入力を -efu 下で処理できる'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" res 'abcXYZ012-._~'
      The status should be success
    End

    It '制御文字と保持区間の混在を -efu 下で処理できる'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" res "${SX_STR_LF}a/b ${SX_STR_HT}z%"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '結果変数名の省略を -efu 下で拒否する'
    When run efu_run sx_uri_enc
    The status should equal 64
  End

  It '不正な結果変数名を -efu 下で拒否する'
    When run efu_run sx_uri_enc 'res:other' input
    The status should equal 64
  End

  It '読み取り専用の結果変数を -efu 下で拒否する'
    readonly res=before
    When run efu_run sx_uri_enc res input
    The status should equal 77
    The stderr should equal ''
  End

  It '余分な引数を -efu 下で拒否する'
    When run efu_run sx_uri_enc res input extra
    The status should equal 64
  End
End
