# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
Describe 'sx_arr_splice -efu 環境検証'
  Include ./spec/support/run.sh
  Include ./spec/support/library.sh sx_arr_splice

  It '正常動作し、子シェル内で内部変数が漏洩しないこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d

    splice_and_check_leaks() {
      sx_arr_splice "$@"
      # When runの子シェル内で検査し、親側のAfterEachから見えない漏洩も検知する。
      check_no_leak
    }
    When run efu_run splice_and_check_leaks myarr 1 2 X Y
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It '参照値とリテラルの混在でも -efu 下で値と順序を保持すること'
    Set 'allexport:on'
    src="reference"
    setup_command='
      SX_SYS_REV=$1
      sx_arr_gen myarr head tail
      sx_cfg_set "ARR_REF=@"
    '
    sxtest_run myarr SX_CFG_ARR_REF SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
    # spliceで変更されない要素も、事後検証用の子シェルへ渡す。
    export myarr myarr_len myarr_0 myarr_1
    splice_ref_efu() {
      sx_arr_splice myarr 1 0 "@src" literal
      result=
      sxtest_run result -- 'sx_arr_quote result myarr'
      printf '%s\n' "${result}"
    }
    When run efu_run splice_ref_efu
    The status should be success
    The stdout should equal "'head' 'reference' 'literal' 'tail'"
    sxtest_run SX_CFG_ARR_REF -- 'sx_cfg_set "$@"' "ARR_REF"
    sxtest_run myarr myarr_len myarr_0 myarr_1 myarr_2 myarr_3 src -- \
      'sx_var_unset "$@"' myarr myarr_len myarr_0 myarr_1 myarr_2 myarr_3 src
  End

  It '負数でも -efu 下で動作すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d

    When run efu_run sx_arr_splice myarr -1 1 X
    The status should be success
  End

  It 'del が負でも -efu 下で動作すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d

    When run efu_run sx_arr_splice myarr 1 -1
    The status should be success
  End

  It '負数の複合でも -efu 下で動作すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d

    When run efu_run sx_arr_splice myarr -2 -1 X
    The status should be success
  End

  It '不正形式でも -efu 下で EX_USAGE を返すこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b

    When run efu_run sx_arr_splice myarr 01 1 X
    The status should equal 64
  End
End
