#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '機能ごとの個別生成'
  It '単独・複数生成、再生成、失敗時の出力保持を検証すること'
    When run python3 spec/build/modules_test.py
    The status should be success
    The output should include 'OK'
  End
End
