Describe 'sx_num_is_int_safe_inv'
  Include ./sx.sh

  It '反転可能な整数を受け入れること'
    When call sx_num_is_int_safe_inv "0" "1" "-1" "123" "-123"
    The status should be success
  End

  It 'INT_MIN を拒否すること'
    # Assuming default 32-bit range
    When call sx_num_is_int_safe_inv "-2147483648"
    The status should be failure
  End

  It 'INT_MIN 直上の値を受け入れること'
    When call sx_num_is_int_safe_inv "-2147483647"
    The status should be success
  End

  It '整数以外の値を拒否すること'
    When call sx_num_is_int_safe_inv "abc"
    The status should be failure
  End

  It '範囲外の値を拒否すること'
    When call sx_num_is_int_safe_inv "2147483648"
    The status should be failure
  End

  It 'いずれかの引数が無効な場合に拒否すること'
    When call sx_num_is_int_safe_inv "1" "-2147483648" "2"
    The status should be failure
  End
End
