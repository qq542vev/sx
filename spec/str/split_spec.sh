Describe 'sx_str_split'
  Include ./sx.sh
  It 'splits a string into an array'
    When call sx_str_split myarr "a:b:c:d" ":"
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_3 should equal "d"
  End

  It 'splits with limit (forward)'
    When call sx_str_split myarr "a:b:c:d" ":" 2 f
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c:d"
  End

  It 'splits with limit (backward)'
    When call sx_str_split myarr "a:b:c:d" ":" 2 b
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a:b"
    The variable myarr_1 should equal "c"
    The variable myarr_2 should equal "d"
  End

  It 'handles special characters'
    When call sx_str_split myarr "a'b:c\"d" ":" 1 f
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "a'b"
    The variable myarr_1 should equal "c\"d"
  End

  It 'handles empty input string'
    When call sx_str_split myarr "" ":" 5 f
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal ""
  End
End
