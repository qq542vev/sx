#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '選択した名前の依存解決と部分版ビルド'
  It '循環・重複・未知の名前と全体版との一致を検証すること'
    When run python3 spec/build/bundle_test.py
    The status should be success
    The output should include 'OK'
  End
End
