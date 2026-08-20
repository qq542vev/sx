#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_min -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_min result 0x10 15.5 017
    The status should be success
  End
End