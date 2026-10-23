#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# ShellSpec: 参照渡しで設定される変数を使用する。
# shellcheck disable=SC2154

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_touch'
  Include ./spec/support/setup.sh
  Include ./spec/support/library.sh sx_var_touch
  It '変数のリビジョンを更新すること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a
    old_val="${myarr}"
    When call sx_var_touch myarr
    The status should be success
    The variable myarr should not equal "${old_val}"
    The variable myarr should start with "array-sx-sig-"
  End

  It '複数の変数を同時に更新できること'
    setup_command='
      SX_SYS_REV=$1
      sx_arr_gen arr1 a
      sx_arr_gen arr2 b
    '
    sxtest_setup arr1 arr2 SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
    old1="${arr1}"
    old2="${arr2}"
    When call sx_var_touch arr1 arr2
    The status should be success
    The variable arr1 should not equal "${old1}"
    The variable arr2 should not equal "${old2}"
  End

  It '読み取り専用変数の場合に EX_NOPERM を返すこと'
    readonly ro_touch=ro
    When call sx_var_touch ro_touch
    The status should equal 77
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_touch "1invalid"
    The status should equal 64
  End
End
