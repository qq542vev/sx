Describe 'sx_var_copy'
  Include ./sx.sh
  It '右シフトコピー（v1 -> v2 -> v3）を行うこと'
    v1=AAA v2=BBB v3=CCC
    When call sx_var_copy v1 v2 v3
    The status should be success
    The variable v1 should equal "AAA"
    The variable v2 should equal "AAA"
    The variable v3 should equal "BBB"
  End

  It 'チェーン内の未設定変数を処理できること'
    u0=START
    unset u1 u2
    When call sx_var_copy u0 u1 u2
    The status should be success
    The variable u1 should equal "START"
    The variable u2 should be undefined
  End

  It 'コピー先が読み取り専用の場合にEX_NOPERM (77)を返すこと'
    a1=1
    readonly r1_copy=READONLY
    When call sx_var_copy a1 r1_copy
    The status should equal 77
  End
End
