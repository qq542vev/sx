Describe 'sx_num_div_nat0 -efu 環境検証'
  sxtest_load ./build/modules/sx_num_div_nat0.sh

  It '正常動作'

    When run efu_run sx_num_div_nat0 d 2 100 3
    The status should be success
  End

  Context '公開関数と内部関数の省略引数'
    Parameters
      sx_num_div_nat0 0
      sx_num_div_nat0 1
      __sx_num_div_nat0 0
    End

    It '小数桁数と被除数を省略しても-e下で正常終了すること'
      divide_defaults() {
        SX_CFG_SKIP_CHK=$2
        "$1" d
        printf '%s\n' "$d"
      }

      When run efu_run divide_defaults "$1" "$2"
      The status should be success
      The output should equal 0
      The stderr should equal ''
    End

    It '被除数だけを省略しても-e下で正常終了すること'
      divide_default_dividend() {
        SX_CFG_SKIP_CHK=$2
        "$1" d 2
        printf '%s\n' "$d"
      }

      When run efu_run divide_default_dividend "$1" "$2"
      The status should be success
      The output should equal 0
      The stderr should equal ''
    End
  End
End
