Describe 'sx_cfg_is_valid -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_cfg_is_valid "NUM_RANGE=64"
    The status should be success
  End
End
