#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'テスト用モジュールの読み込み宣言'
  It '全テストの提供名と出力先を照合すること'
    When run python3 tools/build-spec-modules.py --check spec
    The status should be success
    The output should include 'テスト用モジュールを照合しました'
  End

  It '依存の分離、不正な宣言、読み込み先の選択を検証すること'
    When run python3 spec/build/spec_modules_test.py
    The status should be success
    The output should include 'OK'
  End
End
