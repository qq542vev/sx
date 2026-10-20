#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '関数の個別展開と結合'
  It '元ソースと定数の分割ファイルが同期していること'
    When run python3 tools/split-constants.py --check
    The status should be success
    The output should include '全定数の読み込み一覧1ファイル'
  End

  It '元ソースと関数の分割ファイルが同期していること'
    When run python3 tools/split-functions.py --check
    The status should be success
    The output should include '全関数の読み込み一覧1ファイル'
  End

  It '全関数の単独展開・スコープ保持・結合結果を検証すること'
    When run python3 spec/build/split_functions_test.py
    The status should be success
    The output should include 'OK'
  End
End
