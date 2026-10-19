Describe 'sx_cfg_set -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_cfg_set "SIG_ARR=new-sig" "NUM_RANGE=64"
    The status should be success
  End

  It 'メタ情報への設定を64で拒否すること'
    When run efu_run sx_cfg_set META_NAMES=invalid
    The status should equal 64
    The stderr should equal ''
  End

  Context '引数なしの全設定リセット'
    Parameters
      0
      1
    End

    It "SKIP_CHK=$1 から全設定をリセットできること"
      sx_cfg_set NUM_RANGE=64 SIG_ARR=custom "SKIP_CHK=${1}"
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
      sx_cfg_set NUM_RANGE=64 SIG_ARR=custom
      readonly "${1}"
      When run efu_run sx_cfg_set
      The status should equal 77
      The stderr should equal ''
    End
  End

  Context '廃止された SIG_BASE の拒否'
    Parameters
      'SIG_BASE'
      'SIG_BASE=custom'
    End

    It "$1 を64で拒否すること"
      When run efu_run sx_cfg_set "${1}"
      The status should equal 64
      The stderr should equal ''
    End
  End
End
