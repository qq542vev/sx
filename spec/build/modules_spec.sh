#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'module.mk による個別生成'
  It '全単位の列挙・更新判定・個別生成・失敗時の出力保持を検証すること'
    When run python3 spec/build/modules_test.py
    The status should be success
    The output should include 'OK'
  End
End
