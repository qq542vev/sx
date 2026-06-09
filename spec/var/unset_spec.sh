#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_unset'
  Include ./sx.sh
  It '通常の変数を未設定にすること'
    a=1
    When call sx_var_unset a
    The status should be success
    The variable a should be undefined
  End

  It '配列とそのすべての要素を未設定にすること'
    sx_arr_gen myarr a b c
    When call sx_var_unset myarr
    The status should be success
    The variable myarr should be undefined
    The variable myarr_len should be undefined
    The variable myarr_0 should be undefined
    The variable myarr_2 should be undefined
  End

  It '変数が読み取り専用の場合（未設定であっても）に EX_NOPERM を返すこと'
    readonly ro_var_unset
    When call sx_var_unset ro_var_unset
    The status should equal 77
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_unset "invalid-name"
    The status should equal 64
  End

  It '未設定の変数をunsetしても成功すること'
    When call sx_var_unset nonexistent_uns
    The status should be success
  End

  It '複数の変数を同時にunsetできること'
    a_uns=1 b_uns=2
    When call sx_var_unset a_uns b_uns
    The variable a_uns should be undefined
    The variable b_uns should be undefined
  End

  It '配列の中間要素のみをunsetできること'
    sx_arr_gen myarr_uns a b c
    When call sx_var_unset myarr_uns_1
    The variable myarr_uns_0 should equal "a"
    The variable myarr_uns_1 should be undefined
    The variable myarr_uns_2 should equal "c"
  End

  It '多数（10個以上）の変数を一括unsetできること'
    v_u1=1 v_u2=2 v_u3=3 v_u4=4 v_u5=5
    v_u6=6 v_u7=7 v_u8=8 v_u9=9 v_u10=10
    When call sx_var_unset v_u1 v_u2 v_u3 v_u4 v_u5 v_u6 v_u7 v_u8 v_u9 v_u10
    The variable v_u1 should be undefined
    The variable v_u10 should be undefined
  End
End
