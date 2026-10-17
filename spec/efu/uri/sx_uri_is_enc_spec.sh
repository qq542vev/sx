# shellcheck shell=sh

Describe 'sx_uri_is_enc -efu 環境検証'
  Include ./sx.sh

  Context '公開・内部・検証省略'
    Parameters
      sx_uri_is_enc 0
      sx_uri_is_enc 1
      __sx_uri_is_enc 0
    End

    It '入力なしを -efu 下で判定する'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1"
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It '空文字列と複数入力を -efu 下で判定する'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" '' 'abc' '%20%41%ff'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It '日本語を -efu 下で判定する'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" 'あいうabc'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '予約文字と改行を -efu 下で判定する'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" "a/b?c${SX_STR_LF}"
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '途切れた表記を -efu 下で判定する'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" 'abc%2'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な16進数字を -efu 下で判定する'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" 'abc%GG'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It 'NUL 表記を -efu 下で判定する'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" 'abc' '%00' '%20'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It 'NUL の二重表記を -efu 下で判定する'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" '%2500' '%25%30%30'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

  End
End
