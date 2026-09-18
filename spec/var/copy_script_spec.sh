#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_copy_script'
  Include ./sx.sh

  It '右方向連鎖式のコピースクリプトを生成すること'
    When call sx_var_copy_script result "a-b-c"
    The status should be success
    # a->b, b->c (未設定のため unset 形式)
    The variable result should include "__sx_var_unset b"
    The variable result should include "unset b"
    The variable result should include "__sx_var_unset c"
    The variable result should include "unset c"
  End

  It '左方向連鎖式のコピースクリプトを生成すること'
    When call sx_var_copy_script result "a=b=c"
    The status should be success
    # a<-b, b<-c (未設定のため unset 形式)
    The variable result should include "__sx_var_unset b"
    The variable result should include "unset b"
    The variable result should include "__sx_var_unset a"
    The variable result should include "unset a"
  End

  It '設定済み変数の値を埋め込んだ代入式を生成すること'
    vsrc="hello"
    When call sx_var_copy_script result "vsrc-vdst"
    The status should be success
    The variable result should include "__sx_var_unset vdst"
    The variable result should include "vdst='hello'"
  End

  It '単一引用符を含む値を逃避して生成すること'
    qsrc="it's"
    When call sx_var_copy_script result "qsrc-qdst"
    The status should be success
    The variable result should include "qdst='it'\\''s'"
  End

  It '配列の構造を反映したコピースクリプトを生成すること'
    sx_arr_gen myarr x y
    When call sx_var_copy_script result "myarr-newarr"
    The status should be success
    The variable result should include "__sx_var_unset newarr"
    The variable result should include "newarr_len='2'"
    The variable result should include "newarr_0='x'"
    The variable result should include "newarr_1='y'"
  End

  It '生成されたスクリプトが eval で実行できること'
    esrc="va'l"
    sx_var_copy_script script "esrc-edst"
    # shellcheck disable=SC2154 # script は上記関数内で代入される
    When call eval "$script"
    The status should be success
    The variable edst should equal "va'l"
  End

  It '引数が単一の変数名の場合は空文字列を格納すること'
    When call sx_var_copy_script result "a"
    The status should be success
    The variable result should equal ""
  End

  It '無効な連鎖式に対して EX_USAGE を返すこと'
    When call sx_var_copy_script result "a+b"
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_copyls="fixed"
    When call sx_var_copy_script ro_res_copyls "a-b"
    The status should equal 77
  End
End
