Describe 'sx_str_has'
  Include ./sx.sh

  Context '基本機能テスト'
    It '単一の一致する文字列を検索する場合に成功を返すこと'
      When call sx_str_has "hello world" "world"
      The status should be success
    End

    It '複数の一致する文字列を検索する場合に成功を返すこと'
      When call sx_str_has "hello world" "hello" "world"
      The status should be success
    End

    It '一致するものが見つからない場合に失敗を返すこと'
      When call sx_str_has "hello world" "earth"
      The status should be failure
    End

    It '複数の不一致な文字列を検索する場合に失敗を返すこと'
      When call sx_str_has "hello world" "foo" "bar" "baz"
      The status should be failure
    End
  End

  Context '空文字列テスト'
    It '空文字列を検索した場合に成功を返すこと'
      When call sx_str_has "hello" ""
      The status should be success
    End

    It '空文字列を検索対象として指定した場合に成功を返すこと'
      When call sx_str_has "" ""
      The status should be success
    End

    It '空文字列を複数検索対象として指定した場合に成功を返すこと'
      When call sx_str_has "hello" "" "world"
      The status should be success
    End

    It '空文字列のみを検索対象として指定した場合に成功を返すこと'
      When call sx_str_has "hello" ""
      The status should be success
    End
  End

  Context '部分一致テスト'
    It '文字列の先頭部分が一致する場合に成功を返すこと'
      When call sx_str_has "hello world" "hello"
      The status should be success
    End

    It '文字列の末尾部分が一致する場合に成功を返すこと'
      When call sx_str_has "hello world" "world"
      The status should be success
    End

    It '文字列の中央部分が一致する場合に成功を返すこと'
      When call sx_str_has "hello world" "lo wo"
      The status should be success
    End

    It '文字列の一部が一致する場合に成功を返すこと'
      When call sx_str_has "hello world" "ell"
      The status should be success
    End
  End

  Context '特殊文字テスト'
    It 'スペースを含む文字列の検索'
      When call sx_str_has "hello world" "hello world"
      The status should be success
    End

    It 'タブ文字を含む文字列の検索'
      When call sx_str_has "hello	world" "hello"
      The status should be success
    End

    It '改行文字を含む文字列の検索'
      When call sx_str_has "hello\nworld" "hello"
      The status should be success
    End

    It '記号を含む文字列の検索'
      When call sx_str_has "hello@world" "hello@"
      The status should be success
    End

    It '数字を含む文字列の検索'
      When call sx_str_has "hello123world" "123"
      The status should be success
    End
  End

  Context '大文字小文字テスト'
    It '大文字と小文字が一致する場合に成功を返すこと'
      When call sx_str_has "Hello World" "Hello"
      The status should be success
    End

    It '大文字と小文字が不一致な場合に失敗を返すこと'
      When call sx_str_has "Hello World" "hello"
      The status should be failure
    End

    It '大文字と小文字が混在する検索'
      When call sx_str_has "Hello World" "WoRlD"
      The status should be failure
    End
  End

  Context '境界値テスト'
    It '検索対象文字列が1文字の場合'
      When call sx_str_has "a" "a"
      The status should be success
    End

    It '検索対象文字列が1文字で不一致の場合'
      When call sx_str_has "a" "b"
      The status should be failure
    End

    It '検索対象文字列が非常に長い場合'
      When call sx_str_has "$(printf 'a%.0s' {1..1000})" "a"
      The status should be success
    End

    It '検索パターンが非常に長い場合'
      When call sx_str_has "hello" "$(printf 'a%.0s' {1..100})"
      The status should be failure
    End
  End

  Context '複数検索パターンテスト'
    It '最初の検索パターンが一致する場合'
      When call sx_str_has "hello world" "hello" "foo" "bar"
      The status should be success
    End

    It '最後の検索パターンが一致する場合'
      When call sx_str_has "hello world" "foo" "bar" "world"
      The status should be success
    End

    It '複数の検索パターンが一致する場合'
      When call sx_str_has "hello world" "hello" "world" "foo"
      The status should be success
    End

    It '検索パターンが重複する場合'
      When call sx_str_has "hello world" "hello" "hello" "world"
      The status should be success
    End
  End

  Context '引数の数テスト'
    It '引数指定がない場合'
      When call sx_str_has
      The status should be failure
    End

    It '検索対象文字列のみを指定した場合（検索パターンなし）'
      When call sx_str_has "hello"
      The status should be failure
    End

    It '検索対象文字列と1つの検索パターンを指定した場合'
      When call sx_str_has "hello world" "hello"
      The status should be success
    End

    It '検索対象文字列と複数の検索パターンを指定した場合'
      When call sx_str_has "hello world" "hello" "world" "foo"
      The status should be success
    End
  End

  Context '特殊ケーステスト'
    It '検索対象が空文字列で検索パターンが空文字列の場合'
      When call sx_str_has "" ""
      The status should be success
    End

    It '検索対象が空文字列で検索パターンが非空の場合'
      When call sx_str_has "" "hello"
      The status should be failure
    End

    It '検索対象が空文字列で複数の検索パターンを指定した場合'
      When call sx_str_has "" "hello" "world" ""
      The status should be success
    End

    It '検索パターンに空文字列が含まれる場合'
      When call sx_str_has "hello world" "hello" "" "world"
      The status should be success
    End
  End

  Context 'パフォーマンス関連テスト'
    It '長い文字列内での部分一致検索'
      When call sx_str_has "$(printf 'a%.0s' {1..1000})b" "b"
      The status should be success
    End

    It '長い文字列内での不一致検索'
      When call sx_str_has "$(printf 'a%.0s' {1..1000})" "b"
      The status should be failure
    End
  End
End
