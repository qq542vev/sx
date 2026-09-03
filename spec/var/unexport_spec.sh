#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_unexport'
  Include ./sx.sh
  It 'エクスポート属性を解除しつつ値を保持すること'
    a_unexport=1
    export a_unexport
    When call sx_var_unexport a_unexport
    The status should be success
    The variable a_unexport should equal "1"
    The value "$(env | grep '^a_unexport=')" should be blank
  End

  It '値を保持したまま環境変数から消えること'
    s_unexport="hello world"
    export s_unexport
    When call sx_var_unexport s_unexport
    The status should be success
    The variable s_unexport should equal "hello world"
    The value "$(env | grep '^s_unexport=')" should be blank
  End

  It '読み取り専用の変数に対して EX_NOPERM を返すこと'
    readonly ro_var_unexport=1
    export ro_var_unexport
    When call sx_var_unexport ro_var_unexport
    The status should equal 77
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_unexport "invalid-name"
    The status should equal 64
  End

  It '未エクスポートの変数を指定しても成功すること'
    plain_var_unexport=1
    When call sx_var_unexport plain_var_unexport
    The status should be success
    The variable plain_var_unexport should equal "1"
  End

  It '未設定の変数を指定しても成功すること'
    When call sx_var_unexport nonexistent_unx
    The status should be success
  End

  It '複数の変数を同時に解除できること'
    a_multi=1 b_multi=2
    export a_multi b_multi
    When call sx_var_unexport a_multi b_multi
    The status should be success
    The value "$(env | grep '^a_multi=')" should be blank
    The value "$(env | grep '^b_multi=')" should be blank
  End

  It '特殊文字を含む値を保持できること'
    v_special='a b "quote" $dollar'
    export v_special
    When call sx_var_unexport v_special
    The status should be success
    The variable v_special should equal 'a b "quote" $dollar'
  End
End
