Describe 'sx_const_check'
  Include ./sx.sh
  It 'SX_EX_USAGE が関数内で定義されていること'
    check() { echo "$SX_EX_USAGE"; }
    When call check
    The stdout should equal "64"
  End
End
