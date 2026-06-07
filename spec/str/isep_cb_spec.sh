#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_isep (callback)'
  Include ./sx.sh

  It '正方向のコールバックで動的セパレータを挿入すること'
    cb() { __sx_var_set "${1}=($4)"; }
    When call sx_str_isep res "123456" cb 2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12(1)34(2)56"
  End

  It '逆方向のコールバックで動的セパレータを挿入すること'
    cb() { __sx_var_set "${1}=($4)"; }
    When call sx_str_isep res "12345" cb -2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "1(2)23(1)45"
  End

  It 'コールバック引数 (left, right, count) が正しいこと (Forward)'
    # callback res left right count
    cb() { __sx_var_set "${1}=:${2}|${3}:${4}"; }
    
    # Forward: 123456, int=2
    # 1st: left=12, right=3456, count=1
    # 2nd: left=1234, right=56, count=2
    When call sx_str_isep res "123456" cb 2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12:12|3456:134:1234|56:256"
  End

  It 'コールバック引数 (left, right, count) が正しいこと (Backward)'
    cb() { __sx_var_set "${1}=:${2}|${3}:${4}"; }
    
    # Backward: 123456, int=-2
    # 1st: left=1234, right=56, count=1
    # 2nd: left=12, right=3456, count=2
    When call sx_str_isep res "123456" cb -2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12:12|3456:234:1234|56:156"
  End

  It 'ab に対する正方向 (int=1) の left/right が正しいこと'
    cb() { __sx_var_set "${1}=[${2}:${3}]"; }
    When call sx_str_isep res "ab" cb 1 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "a[a:b]b"
  End

  It 'ab に対する逆方向 (int=-1) の left/right が正しいこと'
    cb() { __sx_var_set "${1}=[${2}:${3}]"; }
    When call sx_str_isep res "ab" cb -1 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "a[a:b]b"
  End

  It 'リミットがコールバックでも機能すること'
    cb() { __sx_var_set "${1}=*"; }
    When call sx_str_isep res "123456" cb 2 1 "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12*3456"
  End

  It 'コールバックが非0を返すと正方向の挿入を中断すること'
    cb_stop() {
      __sx_var_set "${1}=!"
      [ "$4" -lt 2 ] # count=2 で非0を返す
    }
    # 1st: left=12, count=1 -> returns 0, inserts !
    # 2nd: left=1234, count=2 -> returns 1, inserts !, stops
    When call sx_str_isep res "123456" cb_stop 2 "" "$SX_STR_ISEP_CB"
    The status should be failure
    The variable res should equal "12!34!56"
  End

  It 'コールバックが非0を返すと逆方向の挿入を中断すること'
    cb_stop() {
      __sx_var_set "${1}=!"
      [ "$4" -lt 2 ] # count=2 で非0を返す
    }
    # Backward "123456" int=-2
    # 1st: right=56, count=1 -> returns 0, inserts !
    # 2nd: right=3456, count=2 -> returns 1, inserts !, stops
    When call sx_str_isep res "123456" cb_stop -2 "" "$SX_STR_ISEP_CB"
    The status should be failure
    The variable res should equal "12!34!56"
  End

  Context 'SX_STR_ISEP_PRE / POST フラグ (コールバック)'
    It 'SX_STR_ISEP_PRE で先頭コールバックを呼び出すこと'
      cb() { __sx_var_set "${1}=<${2}:${3}:${4}>"; }
      # Forward "abc", int=1, PRE
      # 1st: PRE -> left="", right="abc", count=1
      # 2nd: loop -> left="a", right="bc", count=2
      # 3rd: loop -> left="ab", right="c", count=3
      When call sx_str_isep res "abc" cb 1 "" $((SX_STR_ISEP_CB | SX_STR_ISEP_PRE))
      The status should be success
      The variable res should equal "<:abc:1>a<a:bc:2>b<ab:c:3>c"
    End

    It 'SX_STR_ISEP_POST で末尾コールバックを呼び出すこと'
      cb() { __sx_var_set "${1}=<${2}:${3}:${4}>"; }
      # Forward "abc", int=1, POST
      # 1st: loop -> left="a", right="bc", count=1
      # 2nd: loop -> left="ab", right="c", count=2
      # 3rd: POST -> left="abc", right="", count=3
      When call sx_str_isep res "abc" cb 1 "" $((SX_STR_ISEP_CB | SX_STR_ISEP_POST))
      The status should be success
      The variable res should equal "a<a:bc:1>b<ab:c:2>c<abc::3>"
    End

    It '逆方向での PRE | POST コールバック'
      cb() { __sx_var_set "${1}=($4)"; }
      # Backward "1234", int=-2, PRE | POST
      # 1st: POST -> count=1
      # 2nd: loop -> count=2
      # 3rd: PRE  -> count=3
      When call sx_str_isep res "1234" cb -2 "" $((SX_STR_ISEP_CB | SX_STR_ISEP_PRE | SX_STR_ISEP_POST))
      The status should be success
      The variable res should equal "(3)12(2)34(1)"
    End

    It '空文字列に対して PRE|POST を指定した場合 (コールバック)'
      cb() { __sx_var_set "${1}=A"; }
      When call sx_str_isep res "" cb 1 "" $((SX_STR_ISEP_CB | SX_STR_ISEP_PRE | SX_STR_ISEP_POST))
      The status should be success
      The variable res should equal "A"
    End
  End
End
