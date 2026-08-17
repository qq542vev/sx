Describe 'sx_cfg_set -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_cfg_set "SIG_BASE=new-sig" "NUM_RANGE=64"
    The status should be success
  End
End
