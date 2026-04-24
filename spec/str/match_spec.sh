Describe 'sx_str_match'
  Include ./sx.sh
  It '第1引数がそれ以降のいずれかのパターン（glob）に一致する場合に成功を返すこと'
    When call sx_str_match "file.txt" "*.txt" "*.md"
    The status should be success
  End

  It 'どのパターンにも一致しない場合に失敗を返すこと'
    When call sx_str_match "file.txt" "*.md"
    The status should be failure
  End

  It 'glob内の文字クラスを処理できること'
    When call sx_str_match "file1" "file[0-9]"
    The status should be success
  End
End
