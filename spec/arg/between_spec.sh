#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_between'
  sxtest_load ./build/modules/sx_arg_between.sh

  Describe '範囲判定（閉区間 [min, max]）'
    It '個数が範囲内の場合に成功すること'
      When call sx_arg_between 1 3 a b
      The status should be success
    End

    It '個数が下限 min と等しい場合に成功すること'
      When call sx_arg_between 2 4 a b
      The status should be success
    End

    It '個数が上限 max と等しい場合に成功すること'
      When call sx_arg_between 1 2 a b
      The status should be success
    End

    It '個数が下限 min 未満の場合に 1 を返すこと'
      When call sx_arg_between 3 5 a b
      The status should equal 1
    End

    It '個数が上限 max 超の場合に 1 を返すこと'
      When call sx_arg_between 1 2 a b c
      The status should equal 1
    End

    It '対象引数が0個で min が 0 の場合に成功すること'
      When call sx_arg_between 0 2
      The status should be success
    End

    It '対象引数が0個で min と max がともに0の場合に成功すること'
      When call sx_arg_between 0 0
      The status should be success
    End

    It '対象引数が0個で min が 1 の場合に 1 を返すこと'
      When call sx_arg_between 1 2
      The status should equal 1
    End

    It 'min と max が等しく個数が一致する場合に成功すること'
      When call sx_arg_between 2 2 a b
      The status should be success
    End

    It 'min と max が等しく個数が不一致の場合に 1 を返すこと'
      When call sx_arg_between 2 2 a
      The status should equal 1
    End
  End

  Describe '境界の省略（空文字列）'
    It 'min が空文字列の場合は下限なし（上限 max のみ検証）'
      When call sx_arg_between "" 2 a b
      The status should be success
    End

    It 'min が空文字列で上限超の場合は 1 を返すこと'
      When call sx_arg_between "" 2 a b c
      The status should equal 1
    End

    It 'max が空文字列の場合は上限なし（下限 min のみ検証）'
      When call sx_arg_between 2 "" a b c d
      The status should be success
    End

    It 'max が空文字列で下限未満の場合は 1 を返すこと'
      When call sx_arg_between 2 "" a
      The status should equal 1
    End

    It '両方空文字列の場合は常に成功すること'
      When call sx_arg_between "" "" a b c
      The status should be success
    End

    It '両方空文字列で引数0個の場合も成功すること'
      When call sx_arg_between "" ""
      The status should be success
    End

    It 'max が0で引数0個の場合に成功すること'
      When call sx_arg_between "" 0
      The status should be success
    End

    It 'max が0で引数が1個の場合に範囲外を返すこと'
      When call sx_arg_between "" 0 x
      The status should equal 1
    End

    It '二桁の残り個数も上限超過として判定すること'
      When call sx_arg_between "" 0 a b c d e f g h
      The status should equal 1
    End

    It 'min が1で引数が1個の場合に成功すること'
      When call sx_arg_between 1 "" x
      The status should be success
    End
  End

  Describe '大きな境界値'
    It '算術域を超える min で引数不足を判定すること'
      When call sx_arg_between 999999999999999999999999 "" x
      The status should equal 1
      The stderr should equal ''
    End

    It '算術域を超える max で引数が範囲内と判定されること'
      When call sx_arg_between "" 999999999999999999999999 x
      The status should be success
    End
  End

  Describe '空文字列引数の扱い'
    It '空文字列の引数も1つの引数としてカウントすること'
      When call sx_arg_between 2 2 "" ""
      The status should be success
    End
  End

  Describe '引数エラー (EX_USAGE: 64)'
    It '引数が2個未満（引数なし）の場合は 64 を返すこと'
      When call sx_arg_between
      The status should equal 64
    End

    It '引数が1個だけの場合は 64 を返すこと'
      When call sx_arg_between 1
      The status should equal 64
    End

    It 'min が負数の場合は 64 を返すこと'
      When call sx_arg_between -1 5 a
      The status should equal 64
    End

    It 'max が負数の場合は 64 を返すこと'
      When call sx_arg_between 1 -2 a
      The status should equal 64
    End

    It 'min が非整数の場合は 64 を返すこと'
      When call sx_arg_between abc 5 a
      The status should equal 64
    End

    It 'max が非整数の場合は 64 を返すこと'
      When call sx_arg_between 1 xyz a
      The status should equal 64
    End

    It 'min > max の場合は 64 を返すこと'
      When call sx_arg_between 3 2 a b
      The status should equal 64
    End
  End

  Describe '設定エラー (EX_CONFIG: 78)'
    It 'SX_CFG_NUM_RANGE が不正なら78を返すこと'
      SX_CFG_NUM_RANGE=bogus
      When call sx_arg_between 1 2 a
      The status should equal 78
    End

    It 'SX_CFG_NUM_RANGE が未設定なら78を返すこと'
      unset SX_CFG_NUM_RANGE
      When call sx_arg_between 1 2 a
      The status should equal 78
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It '引数検証をスキップして正しく判定すること'
      SX_CFG_SKIP_CHK=1
      When call sx_arg_between 1 3 a b
      The status should be success
    End

    It '高速モードで範囲外の場合に 1 を返すこと'
      SX_CFG_SKIP_CHK=1
      When call sx_arg_between 1 2 a b c
      The status should equal 1
    End

    It '高速モードでは不正な設定値の検査も省略すること'
      SX_CFG_SKIP_CHK=1
      SX_CFG_NUM_RANGE=bogus
      When call sx_arg_between 1 3 a b
      The status should be success
    End
  End
End
