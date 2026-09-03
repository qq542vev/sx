#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_is_rw'
  Include ./sx.sh

  It '配列要素が読み取り専用でない場合は成功を返すこと'
    sx_arr_gen myarr a b c
    When call sx_arr_is_rw myarr
    The status should be success
  End

  It '要素が読み取り専用の場合に失敗を返すこと'
    arr_len=2 arr_0=a arr_1=b
    readonly arr_0
    When call sx_arr_is_rw arr
    The status should be failure
  End

  It '長さ変数が読み取り専用の場合に失敗を返すこと'
    arr_len=2 arr_0=a arr_1=b
    readonly arr_len
    When call sx_arr_is_rw arr
    The status should be failure
  End

  It '配列名（シグネチャ変数）が読み取り専用の場合に失敗を返すこと'
    sx_arr_gen sig_arr a
    readonly sig_arr
    When call sx_arr_is_rw sig_arr
    The status should be failure
  End

  It '多桁インデックスの要素が読み取り専用の場合に失敗を返すこと'
    arr_len=100
    arr_0=a
    arr_49=mid
    readonly arr_49
    When call sx_arr_is_rw arr
    The status should be failure
  End

  It '複数の要素が読み取り専用の場合に失敗を返すこと'
    arr_len=3 arr_0=a arr_1=b arr_2=c
    readonly arr_0 arr_2
    When call sx_arr_is_rw arr
    The status should be failure
  End

  It 'インデックスでない末尾のスカラ（_foo 等）は要素として誤検知しないこと'
    arr_len=1 arr_0=a
    arr_foo=scalar
    readonly arr_foo
    When call sx_arr_is_rw arr
    The status should be success
  End

  It '別変数が配列名の前方一致でも誤検知しないこと（rlen と rl）'
    rl_len=1 rl_0=a
    rlen=9
    readonly rlen
    When call sx_arr_is_rw rl
    The status should be success
  End

  It '値に改行を含む読み取り専用要素を検出できること'
    newline_arr_len=2
    newline_arr_0="line1
line2"
    readonly newline_arr_0
    When call sx_arr_is_rw newline_arr
    The status should be failure
  End

  It '空値を保持する読み取り専用要素を検出できること'
    arr_len=1
    arr_0=""
    readonly arr_0
    When call sx_arr_is_rw arr
    The status should be failure
  End

  It '複数の配列名を指定して判定できること'
    sx_arr_gen first a
    sx_arr_gen second b
    readonly second_0
    When call sx_arr_is_rw first second
    The status should be failure
  End

  It '無効な配列名に対して EX_USAGE を返すこと'
    When call sx_arr_is_rw "invalid-name"
    The status should equal 64
  End
End
