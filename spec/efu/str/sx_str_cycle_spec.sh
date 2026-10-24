Describe 'sx_str_cycle -efu 環境検証'
  sxtest_load ./build/modules/sx_str_cycle.sh

  It '正常動作'
    When run efu_run sx_str_cycle res "ABCDE" 2
    The status should be success
  End

  Parameters
    '+0'
    '-0'
    '-7'
    '10'
    '100000000000000000000000000000000000002'
    '-100000000000000000000000000000000000002'
  End

  It '境界値をシェル終了なしで処理する'
    When run efu_run sx_str_cycle res 'ABCDE' "$1"
    The status should be success
  End
End
