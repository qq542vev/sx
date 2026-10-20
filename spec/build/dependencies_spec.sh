#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '分割単位の依存宣言'
  It '全単位の宣言が展開後の直接参照と一致すること'
    When run python3 tools/check-dependencies.py
    The status should be success
    The output should include '依存宣言を照合しました'
  End
End
