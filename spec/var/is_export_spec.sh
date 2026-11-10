#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_export'
  sxtest_load ./build/modules/sx_var_is_export.sh
  It 'エクスポート属性付きの変数に対して成功を返すこと'
    export a_export=1
    When call sx_var_is_export a_export
    The status should be success
  End

  It 'エクスポート属性のない変数に対して失敗を返すこと'
    b_noexport=2
    When call sx_var_is_export b_noexport
    The status should be failure
  End

  It '存在しない変数に対して失敗を返すこと'
    unset c_nonexistent
    When call sx_var_is_export c_nonexistent
    The status should be failure
  End

  It '後からエクスポートした変数を認識すること'
    d_late_export=1
    sx_var_is_export d_late_export || :
    export d_late_export
    When call sx_var_is_export d_late_export
    The status should be success
  End

  It '変数を削除した後はエクスポート属性なしと判定すること'
    export e_removed_export=1
    sx_var_is_export e_removed_export
    unset e_removed_export
    When call sx_var_is_export e_removed_export
    The status should be failure
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_is_export "1invalid"
    The status should equal 64
  End
End
