Describe 'sx_str_ew'
  Include ./sx.sh

  Context '基本機能テスト'
    It '単一の一致する接尾辞を持つ場合に成功を返すこと'
      When call sx_str_ew "hello world" "world"
      The status should be success
    End

    It '複数の一致する接尾辞を持つ場合に成功を返すこと'
      When call sx_str_ew "hello world" "world" "ld"
      The status should be success
    End

    It 'いずれの接尾辞でも終わらない場合に失敗を返すこと'
      When call sx_str_ew "hello world" "hell"
      The status should be failure
    End

    It '複数の不一致な接尾辞を持つ場合に失敗を返すこと'
      When call sx_str_ew "hello world" "foo" "bar" "baz"
      The status should be failure
    End
  End

  Context '空文字列テスト'
    It '空文字列を接尾辞として指定した場合に成功を返すこと'
      When call sx_str_ew "hello world" ""
      The status should be success
    End

    It '空文字列を検索対象として指定した場合に成功を返すこと'
      When call sx_str_ew "" "hello"
      The status should be success
    End

    It '空文字列を検索対象と接尾辞の両方に指定した場合に成功を返すこと'
      When call sx_str_ew "" ""
      The status should be success
    End

    It '空文字列を複数の接尾辞として指定した場合に成功を返すこと'
      When call sx_str_ew "hello" "" "world"
      The status should be success
    End
  End

  Context '部分一致テスト'
    It '完全一致する接尾辞を持つ場合に成功を返すこと'
      When call sx_str_ew "hello world" "hello world"
      The status should be success
    End

    It '文字列の末尾部分が一致する場合に成功を返すこと'
      When call sx_str_ew "hello world" "world"
      The status should be success
    End

    It '文字列の一部が一致する場合に成功を返すこと'
      When call sx_str_ew "hello world" "lo wo"
      The status should be success
    End

    It '単一文字の接尾辞を持つ場合に成功を返すこと'
      When call sx_str_ew "hello world" "d"
      The status should be success
    End
  End

  Context '特殊文字テスト'
    It 'スペースを含む接尾辞を持つ場合に成功を返すこと'
      When call sx_str_ew "hello world" "o world"
      The status should be success
    End

    It 'タブ文字を含む接尾辞を持つ場合に成功を返すこと'
      When call sx_str_ew "hello	world" "world"
      The status should be success
    End

    It '改行文字を含む接尾辞を持つ場合に成功を返すこと'
      When call sx_str_ew "hello\nworld" "world"
      The status should be success
    End

    It '記号を含む接尾辞を持つ場合に成功を返すこと'
      When call sx_str_ew "hello@world" "o@world"
      The status should be success
    End

    It '数字を含む接尾辞を持つ場合に成功を返すこと'
      When call sx_str_ew "hello123world" "123world"
      The status should be success
    End
  End

  Context '大文字小文字テスト'
    It '大文字と小文字が一致する場合に成功を返すこと'
      When call sx_str_ew "Hello World" "World"
      The status should be success
    End

    It '大文字と小文字が不一致な場合に失敗を返すこと'
      When call sx_str_ew "Hello World" "world"
      The status should be failure
    End

    It '大文字と小文字が混在する接尾辞を持つ場合に失敗を返すこと'
      When call sx_str_ew "Hello World" "WoRlD"
      The status should be failure
    End
  End

  Context '境界値テスト'
    It '検索対象文字列が1文字の場合'
      When call sx_str_ew "a" "a"
      The status should be success
    End

    It '検索対象文字列が1文字で不一致の場合'
      When call sx_str_ew "a" "b"
      The status should be failure
    End

    It '検索対象文字列が非常に長い場合'
      When call sx_str_ew "$(printf 'a%.0s' {1..1000})b" "b"
      The status should be success
    End

    It '接尾辞が非常に長い場合'
      When call sx_str_ew "hello" "$(printf 'a%.0s' {1..100})"
      The status should be failure
    End

    It '接尾辞が検索対象文字列より長い場合'
      When call sx_str_ew "hello" "hello world"
      The status should be failure
    End
  End

  Context '複数接尾辞テスト'
    It '最初の接尾辞が一致する場合'
      When call sx_str_ew "hello world" "world" "foo" "bar"
      The status should be success
    End

    It '最後の接尾辞が一致する場合'
      When call sx_str_ew "hello world" "foo" "bar" "world"
      The status should be success
    End

    It '複数の接尾辞が一致する場合'
      When call sx_str_ew "hello world" "world" "ld" "foo"
      The status should be success
    End

    It '接尾辞が重複する場合'
      When call sx_str_ew "hello world" "world" "world" "ld"
      The status should be success
    End
  End

  Context '引数の数テスト'
    It '引数指定がない場合'
      When call sx_str_ew
      The status should be failure
    End

    It '検索対象文字列のみを指定した場合（接尾辞なし）'
      When call sx_str_ew "hello"
      The status should be failure
    End

    It '検索対象文字列と1つの接尾辞を指定した場合'
      When call sx_str_ew "hello world" "world"
      The status should be success
    End

    It '検索対象文字列と複数の接尾辞を指定した場合'
      When call sx_str_ew "hello world" "world" "ld" "foo"
      The status should be success
    End
  End

  Context '特殊ケーステスト'
    It '検索対象が空文字列で接尾辞が空文字列の場合'
      When call sx_str_ew "" ""
      The status should be success
    End

    It '検索対象が空文字列で複数の接尾辞を指定した場合'
      When call sx_str_ew "" "hello" "world" ""
      The status should be success
    End

    It '接尾辞に空文字列が含まれる場合'
      When call sx_str_ew "hello world" "hello" "" "world"
      The status should be success
    End

    It '接尾辞が検索対象文字列と完全に一致する場合'
      When call sx_str_ew "hello world" "hello world"
      The status should be success
    End
  End

  Context 'パフォーマンス関連テスト'
    It '長い文字列内での接尾辞検索'
      When call sx_str_ew "$(printf 'a%.0s' {1..1000})b" "b"
      The status should be success
    End

    It '長い文字列内での不一致接尾辞検索'
      When call sx_str_ew "$(printf 'a%.0s' {1..1000})" "b"
      The status should be failure
    End

    It '長い接尾辞を持つ場合'
      When call sx_str_ew "hello" "$(printf 'a%.0s' {1..100})"
      The status should be failure
    End
  End
End
