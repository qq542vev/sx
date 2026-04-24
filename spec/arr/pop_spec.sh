Describe 'sx_arr_pop'
  Include ./sx.sh
  BeforeEach 'sx_arr_gen myarr a b c'

  It 'pops and discards the last element by default'
    When call sx_arr_pop myarr
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_2 should be undefined
  End

  It 'pops the last element into a variable'
    When call sx_arr_pop myarr v1
    The status should be success
    The variable v1 should equal "c"
    The variable myarr_len should equal 2
    The variable myarr_2 should be undefined
  End

  It 'pops multiple elements into variables'
    When call sx_arr_pop myarr v1 v2
    The status should be success
    The variable v1 should equal "c"
    The variable v2 should equal "b"
    The variable myarr_len should equal 1
    The variable myarr_2 should be undefined
    The variable myarr_1 should be undefined
  End

  It 'pops multiple elements using numeric argument (to discard)'
    When call sx_arr_pop myarr 2
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_2 should be undefined
    The variable myarr_1 should be undefined
  End

  It 'handles popping 0 elements'
    When call sx_arr_pop myarr 0
    The status should be success
    The variable myarr_len should equal 3
  End

  It 'returns failure if popping more elements than available'
    When call sx_arr_pop myarr 4
    The status should be failure
  End

  It 'returns failure if the target is not an array'
    not_an_arr="val"
    When call sx_arr_pop not_an_arr
    The status should equal 65 # SX_EX_DATAERR
  End
End
