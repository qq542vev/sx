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

  It 'コールバック引数 (prev, next, count) が正しいこと (Forward)'
    # callback res prev next count
    cb() { __sx_var_set "${1}=:${2}|${3}:${4}"; }
    
    # Forward: 123456, int=2
    # 1st: prev=12, next=3456, count=1
    # 2nd: prev=1234, next=56, count=2
    When call sx_str_isep res "123456" cb 2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12:12|3456:134:1234|56:256"
  End

  It 'コールバック引数 (prev, next, count) が正しいこと (Backward)'
    cb() { __sx_var_set "${1}=:${2}|${3}:${4}"; }
    
    # Backward: 123456, int=-2
    # 1st: prev=56, next=1234, count=1 (Backward calls it differently: next=2, prev=11+10)
    # Wait, let's check Backward logic in sx.m4:
    # "${3}" __sx_str_isep_cb_ "${2}" "${11}${10}" "${9}"
    # $2: prev_str (remains), $11: chunk, $10: ctx
    # In Backward, "prev" in callback means "string BEFORE insertion point" (which is the remaining string on the left)
    # and "next" means "string AFTER insertion point" (which is the already processed string on the right)
    
    # Backward: 123456, int=-2
    # 1st: prev=1234, next=56, count=1
    # 2nd: prev=12, next=3456, count=2
    When call sx_str_isep res "123456" cb -2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12:12|3456:234:1234|56:156"
  End

  It 'ab に対する正方向 (int=1) の prev/next が正しいこと'
    cb() { __sx_var_set "${1}=[${2}:${3}]"; }
    When call sx_str_isep res "ab" cb 1 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "a[a:b]b"
  End

  It 'ab に対する逆方向 (int=-1) の prev/next が正しいこと'
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
    # 1st: prev=12, count=1 -> returns 0, inserts !
    # 2nd: prev=1234, count=2 -> returns 1, inserts !, stops
    When call sx_str_isep res "123456" cb_stop 2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12!34!56"
  End

  It 'コールバックが非0を返すと逆方向の挿入を中断すること'
    cb_stop() {
      __sx_var_set "${1}=!"
      [ "$4" -lt 2 ] # count=2 で非0を返す
    }
    # Backward "123456" int=-2
    # 1st: next=56, count=1 -> returns 0, inserts !
    # 2nd: next=3456, count=2 -> returns 1, inserts !, stops
    When call sx_str_isep res "123456" cb_stop -2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12!34!56"
  End

End
