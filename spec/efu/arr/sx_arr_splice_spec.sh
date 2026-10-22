Describe 'sx_arr_splice -efu 環境検証'
  Include ./spec/support/prepare.sh
  Include ./spec/support/library.sh sx_arr_splice

  It '正常動作'
    sx_test_setup sx_arr_gen myarr a b c d

    When run efu_run sx_arr_splice myarr 1 2 X Y
    The status should be success
  End

  It '参照値とリテラルの混在でも -efu 下で値と順序を保持すること'
    src="reference"
    sx_test_setup sx_arr_gen myarr head tail
    sx_test_setup sx_cfg_set "ARR_REF=@"
    splice_ref_efu() {
      sx_arr_splice myarr 1 0 "@src" literal
      result=
      sx_test_setup sx_arr_quote result myarr
      printf '%s\n' "${result}"
    }
    When run efu_run splice_ref_efu
    The status should be success
    The stdout should equal "'head' 'reference' 'literal' 'tail'"
    sx_test_setup sx_cfg_set "ARR_REF"
    sx_test_setup sx_var_unset myarr src
  End

  It '負数でも -efu 下で動作すること'
    sx_test_setup sx_arr_gen myarr a b c d

    When run efu_run sx_arr_splice myarr -1 1 X
    The status should be success
  End

  It 'del が負でも -efu 下で動作すること'
    sx_test_setup sx_arr_gen myarr a b c d

    When run efu_run sx_arr_splice myarr 1 -1
    The status should be success
  End

  It '負数の複合でも -efu 下で動作すること'
    sx_test_setup sx_arr_gen myarr a b c d

    When run efu_run sx_arr_splice myarr -2 -1 X
    The status should be success
  End

  It '不正形式でも -efu 下で EX_USAGE を返すこと'
    sx_test_setup sx_arr_gen myarr a b

    When run efu_run sx_arr_splice myarr 01 1 X
    The status should equal 64
  End
End
