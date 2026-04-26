Describe 'sx_var_copyls'
  Include ./sx.sh

  It '右方向連鎖式の代入リストを生成すること'
    When call sx_var_copyls result "a-b-c"
    The status should be success
    # a->b, b->c
    The variable result should include "b=a"
    The variable result should include "c=b"
  End

  It '左方向連鎖式の代入リストを生成すること'
    When call sx_var_copyls result "a=b=c"
    The status should be success
    # a<-b, b<-c
    The variable result should include "b=c"
    The variable result should include "a=b"
  End

  It '配列の構造を反映した代入リストを生成すること'
    sx_arr_gen myarr x y
    When call sx_var_copyls result "myarr-newarr"
    The status should be success
    The variable result should include "newarr=myarr"
    The variable result should include "newarr_len=myarr_len"
    The variable result should include "newarr_0=myarr_0"
    The variable result should include "newarr_1=myarr_1"
  End

  It '無効な連鎖式に対して EX_USAGE を返すこと'
    When call sx_var_copyls result "a+b"
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_copyls="fixed"
    When call sx_var_copyls ro_res_copyls "a-b"
    The status should equal 77
  End
End
