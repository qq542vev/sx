#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_is_bindable'
  Include ./sx.sh

  It 'スカラー変数が書き込み可能の場合に成功を返すこと'
    writable=1
    When call sx_arr_is_bindable "writable"
    The status should be success
  End

  It 'スカラー変数が readonly の場合に失敗を返すこと'
    readonly ro_var=1
    When call sx_arr_is_bindable "ro_var"
    The status should equal 1
  End

  It '配列バインド（要素数指定）で配列関連変数が書き込み可能な場合に成功を返すこと'
    arr_len=2 arr_0=a arr_1=b
    When call sx_arr_is_bindable "2arr:"
    The status should be success
  End

  It '配列の _len が readonly の場合に失敗を返すこと'
    arr_len=1 arr_0=a
    readonly arr_len
    When call sx_arr_is_bindable "arr"
    The status should equal 1
  End

  It '複合バインド（スカラー+配列+最終配列）で成功を返すこと'
    a=1 b_len=2 b_0=x b_1=y c_len=1 c_0=z
    When call sx_arr_is_bindable "a:2b:c"
    The status should be success
  End

  It '複合バインドに readonly が含まれる場合に失敗を返すこと'
    a=1 b_len=2 b_0=x b_1=y
    readonly b_len
    When call sx_arr_is_bindable "a:2b:c"
    The status should equal 1
  End

  It '数値スキップセグメントを含むバインド（a:2:c）が _len が readonly でも成功すること'
    a=1 c_len=1 c_0=x
    readonly _len
    When call sx_arr_is_bindable "a:2:c"
    The status should be success
  End

  It '最終セグメントが数値の場合は EX_USAGE (64) を返すこと'
    When call sx_arr_is_bindable "a:2"
    The status should equal 64
  End

  It '単独の数値も EX_USAGE (64) を返すこと'
    When call sx_arr_is_bindable "2"
    The status should equal 64
  End

  It '数値プレフィックス配列（2b:）の _len が readonly の場合に失敗すること'
    b_len=2 b_0=x b_1=y
    readonly b_len
    When call sx_arr_is_bindable "2b:"
    The status should equal 1
  End

  It 'スキップ要素を正しく処理すること'
    a=1 c_len=1 c_0=x
    When call sx_arr_is_bindable "a::c"
    The status should be success
  End

  It 'trailing colon（最終セグメントが空）で _len を追加しないこと'
    a=1 b_len=2 b_0=x b_1=y c=3
    When call sx_arr_is_bindable "a:2b:c:"
    The status should be success
  End

  It '空バインドに対して成功を返すこと'
    When call sx_arr_is_bindable ""
    The status should be success
  End

  It '無効なバインド形式（先頭 0）に対して EX_USAGE (64) を返すこと'
    When call sx_arr_is_bindable "0a"
    The status should equal 64
  End

  It '複数バインド形式のすべてが書き込み可能な場合に成功を返すこと'
    a=1 b=2
    When call sx_arr_is_bindable "a" "b"
    The status should be success
  End

  It '複数バインド形式のうち1つでも readonly があれば失敗すること'
    a=1
    readonly ro=1
    When call sx_arr_is_bindable "a" "ro"
    The status should equal 1
  End

  Context 'SX_CFG_SKIP_CHK が 1 のとき'
    BeforeRun 'SX_CFG_SKIP_CHK=1'

    It '読み取り専用変数に対しては依然として失敗 (1) を返すこと'
      readonly ro=1
      When call sx_arr_is_bindable "ro"
      The status should equal 1
    End

    It '数値スキップセグメントを含むバインドが成功すること'
      a=1 c=2
      When call sx_arr_is_bindable "a:2:c"
      The status should be success
    End
  End
End
