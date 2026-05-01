Describe 'sx_num_is_base_nint'
  Include ./sx.sh

  It '-1以下の整数（"-"符号必須）で成功すること'
    When call sx_num_is_base_nint 10 "-1" "-123"
    The status should be success
  End

  It '0 または 正の数値で失敗すること'
    When call sx_num_is_base_nint 10 "0" "-0" "1" "+1"
    The status should be failure
  End

  It '8進数で-1以下の場合に成功すること'
    When call sx_num_is_base_nint 8 "-01" "-07"
    The status should be success
  End

  It '16進数で-1以下の場合に成功すること'
    When call sx_num_is_base_nint 16 "-0x1" "-0xABC"
    The status should be success
  End
End
