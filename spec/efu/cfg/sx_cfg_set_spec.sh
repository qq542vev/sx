Describe 'sx_cfg_set -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_cfg_set "SIG_BASE=new-sig" "NUM_RANGE=64"
    The status should be success
  End

  Context '引数なしの全設定リセット'
    Parameters
      0
      1
    End

    It "SKIP_CHK=$1 から全設定をリセットできること"
      sx_cfg_set NUM_RANGE=64 SIG_BASE=custom "SKIP_CHK=${1}"
      When run efu_run sx_cfg_set
      The status should be success
      The stderr should equal ''
    End
  End

  Context 'readonly を含む全設定リセット'
    Parameters
      'SX_CFG_SIG_ARR'
      'SX_CFG_ARR_REF'
      'SX_SYS_NUM_MIN'
    End

    It "$1 が readonly ならシェルを異常終了させず77を返すこと"
      sx_cfg_set NUM_RANGE=64 SIG_BASE=custom
      readonly "${1}"
      When run efu_run sx_cfg_set
      The status should equal 77
      The stderr should equal ''
    End
  End
End
