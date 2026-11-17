#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_pint_base16'
  sxtest_load ./build/modules/sx_num_is_pint_base16.sh

  Context '有効な入力'
    It '1 以上の16進数（"+" 符号付き可）で成功を返すこと'
      When call sx_num_is_pint_base16 "0x1" "+0xABC"
      The status should be success
    End

    It '引数なしで成功を返すこと'
      When call sx_num_is_pint_base16
      The status should be success
    End
  End

  Context '無効な入力'
    It '0 または 接頭辞なしの場合に失敗を返すこと'
      When call sx_num_is_pint_base16 "0x0" "F"
      The status should be failure
    End

    It '空文字列の場合に失敗を返すこと'
      When call sx_num_is_pint_base16 ""
      The status should be failure
    End
  End
End
