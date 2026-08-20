#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_max'
  Include ./sx.sh

  It '複数の数値から最大値を取得すること'
    When call sx_num_max result 3 5 2
    The status should be success
    The variable result should equal 5
  End

  It '単一の数値の場合はそのまま返すこと'
    When call sx_num_max result 5
    The status should be success
    The variable result should equal 5
  End

  It '16進数・8進数・小数が混在する場合に正しく最大値を求めること'
    When call sx_num_max result 0x10 15.5 017
    The status should be success
    The variable result should equal "0x10"
  End

  It '指数表記を含む場合に正しく最大値を求めること'
    When call sx_num_max result 1.5 1e2 0.12
    The status should be success
    The variable result should equal "1e2"
  End

  It '負数を含む場合に正しく最大値を求めること'
    When call sx_num_max result -2.5 -2.05 -1
    The status should be success
    The variable result should equal -1
  End

  It '同値の場合は先に現れた値を採用すること'
    When call sx_num_max result 5 5 3
    The status should be success
    The variable result should equal 5
  End

  It '結果が元の表記のまま格納されること'
    When call sx_num_max result 0x10 5
    The status should be success
    The variable result should equal "0x10"
  End

  It '結果変数の既存値を上書きすること'
    result="old"
    When call sx_num_max result 7 3
    The status should be success
    The variable result should equal 7
  End

  It '数値が1つもない場合は EX_USAGE を返すこと'
    When call sx_num_max result
    The status should equal 64
  End

  It '数値形式が不正な場合は EX_USAGE を返すこと'
    When call sx_num_max result a 1
    The status should equal 64
  End

  It '読み取り専用変数の場合に EX_NOPERM を返すこと'
    readonly ro_var_max=1
    When call sx_num_max ro_var_max 1 2
    The status should equal 77
  End

  It '設定エラー(78)を検知すること'
    check_config() {
      SX_CFG_NUM_RANGE=99
      sx_num_max result 1 2
    }
    When call check_config
    The status should equal 78
  End
End