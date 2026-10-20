#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '大域変数の個別展開と初期化'
  It '元ソースと大域変数の分割ファイルが同期していること'
    When run python3 tools/split-globals.py --check
    The status should be success
    The output should include '全大域変数の読み込み一覧1ファイル'
  End

  It '設定値の継承・空値・派生値・カウンタの契約を検証すること'
    When run python3 spec/build/split_globals_test.py
    The status should be success
    The output should include 'OK'
  End
End
