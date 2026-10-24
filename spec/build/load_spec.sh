#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sxtest_load による個別モジュールの読み込み'
  It '引数・環境変数・呼び出し元の状態と読み込み失敗を検証すること'
    When run python3 spec/build/load_test.py
    The status should be success
    The output should include 'OK'
  End
End
