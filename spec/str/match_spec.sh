Describe 'sx_str_match'
  Include ./sx.sh
  It '第1引数がそれ以降のいずれかのパターン（glob）に一致する場合に成功を返すこと'
    When call sx_str_match "file.txt" "*.txt" "*.md"
    The status should be success
  End

  It 'どのパターンにも一致しない場合に失敗を返すこと'
    When call sx_str_match "file.txt" "*.md" "*.sh"
    The status should be failure
  End

  It 'glob内の文字クラスに一致すること'
    When call sx_str_match "file1" "file[0-9]"
    The status should be success
  End

  It 'glob内の文字クラスに一致しないこと'
    When call sx_str_match "fileA" "file[0-9]"
    The status should be failure
  End

  It '否定の文字クラスを処理できること'
    # POSIX sh では [!...]
    When call sx_str_match "fileA" "file[!0-9]"
    The status should be success
  End

  It '空文字列同士をマッチングできること'
    When call sx_str_match "" ""
    The status should be success
  End

  It '空文字列がワイルドカードにマッチすること'
    When call sx_str_match "" "*"
    The status should be success
  End

  It '空のパターンに非空文字列はマッチしないこと'
    When call sx_str_match "a" ""
    The status should be failure
  End

  It '引数がない場合に失敗を返すこと'
    When call sx_str_match
    The status should be failure
  End

  It '検索対象のみが指定された場合（パターンなし）に失敗を返すこと'
    When call sx_str_match "any"
    The status should be failure
  End
End
