Describe 'sx_cfg_is_valid -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_cfg_is_valid "NUM_RANGE=64"
    The status should be success
  End

  It '設定値の空白と空文字を保持して全項目を検査すること'
    sx_cfg_set 'SIG_ARR=custom array *' 'ARR_HOLE=' 'ARR_REF=@ ref'
    When run efu_run sx_cfg_is_valid
    The status should be success
    The stderr should equal ''
  End

  It 'メタ情報の設定名を拒否すること'
    When run efu_run sx_cfg_is_valid META_NAMES
    The status should equal 1
    The stderr should equal ''
  End

  Context '現在の設定の未設定の検出'
    Parameters
      'SX_CFG_SIG_ARR'
      'SX_CFG_SKIP_CHK'
      'SX_CFG_NUM_RANGE'
      'SX_CFG_SEP'
      'SX_CFG_ARR_UPDATE'
      'SX_CFG_ARR_HOLE'
      'SX_CFG_ARR_REF'
    End

    It "$1 が未設定なら未設定変数の展開エラーを起こさず1を返すこと"
      unset "${1}"
      When run efu_run sx_cfg_is_valid
      The status should equal 1
      The stderr should equal ''
    End
  End
End
