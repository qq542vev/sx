#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '分割単位の個別展開と結合'
  It '一覧と実ファイルが一致すること'
    When run python3 tools/check-units.py
    The status should be success
    The output should include '700 単位'
  End

  It '一覧の欠落と重複を検出すること'
    When run python3 spec/build/units_test.py
    The status should be success
    The output should include 'OK'
  End

  It '全関数の単独展開・スコープ保持・結合結果を検証すること'
    When run python3 spec/build/split_functions_test.py
    The status should be success
    The output should include 'OK'
  End
End
