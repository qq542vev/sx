#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_isep (callback)'
  Include ./sx.sh

  It '正方向のコールバックで動的セパレータを挿入すること'
    cb() { __sx_var_set "${1}=($5)"; }
    When call sx_str_isep res "123456" cb 2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12(1)34(2)56"
  End

  It '逆方向のコールバックで動的セパレータを挿入すること'
    cb() { __sx_var_set "${1}=($5)"; }
    When call sx_str_isep res "12345" cb -2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "1(2)23(1)45"
  End

  It 'コールバック引数 (chunk, prev, next) が正しいこと'
    # callback res chunk prev next count
    # chunk を [] で囲み、prev と next を | で区切る
    cb() { __sx_var_set "${1}=-[${2}]:${3}|${4}-"; }
    
    # Forward: 123456, int=2
    # 1st: chunk=12, prev=12, next=3456, count=1
    # 2nd: chunk=34, prev=1234, next=56, count=2
    When call sx_str_isep res "123456" cb 2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12-[12]:12|3456-34-[34]:1234|56-56"
  End

  It '逆方向のコールバック引数が正しいこと'
    cb() { __sx_var_set "${1}=-[${2}]:${3}|${4}-"; }
    
    # Backward: 123456, int=-2
    # 1st: chunk=56, prev=1234, next=56, count=1
    # 2nd: chunk=34, prev=12, next=3456, count=2
    When call sx_str_isep res "123456" cb -2 "" "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12-[34]:12|3456-34-[56]:1234|56-56"
  End

  It 'リミットがコールバックでも機能すること'
    cb() { __sx_var_set "${1}=*"; }
    When call sx_str_isep res "123456" cb 2 1 "$SX_STR_ISEP_CB"
    The status should be success
    The variable res should equal "12*3456"
  End

End
