#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_splice'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_arr_splice.sh

  It '中間の要素を置換すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen myarr "$@"' "${SX_SYS_REV-0}" a b c d
    When call sx_arr_splice myarr 1 2 X Y
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "Y"
    The variable myarr_3 should equal "d"
  End

  It '先頭に挿入すること (del=0)'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr b c
    When call sx_arr_splice myarr 0 0 HEAD
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c"
  End

  It '末尾に挿入すること (n=len)'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 2 0 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_2 should equal "TAIL"
  End

  It '値なしで純削除すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c
    When call sx_arr_splice myarr 1 1
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "c"
    The variable myarr_2 should be undefined
  End

  It '穴だけの削除では要素と長さを保持し、リビジョンを一度更新すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; sx_arr_gen myarr a b c' "${SX_SYS_REV-0}"
    before_rev=$SX_SYS_REV
    When call sx_arr_splice myarr -5 1
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal a
    The variable myarr_1 should equal b
    The variable myarr_2 should equal c
    The variable myarr should equal "${SX_CFG_SIG_ARR}:$before_rev"
    The variable SX_SYS_REV should equal "$((before_rev + 1))"
  End

  Context '削除数0で挿入値なしのリビジョン更新'
    Parameters
      1 0
      1 +0
      1 '-0'
      '-10000000000000000000000' 0
      '-10000000000000000000000' +0
      '-10000000000000000000000' '-0'
    End

    It '要素を保持し、リビジョンを一度更新すること'
      sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; sx_arr_gen myarr a b c' "${SX_SYS_REV-0}"
      before_rev=$SX_SYS_REV
      When call sx_arr_splice myarr "$1" "$2"
      The status should be success
      The variable myarr_len should equal 3
      The variable myarr_0 should equal a
      The variable myarr_1 should equal b
      The variable myarr_2 should equal c
      The variable myarr should equal "${SX_CFG_SIG_ARR}:$before_rev"
      The variable SX_SYS_REV should equal "$((before_rev + 1))"
    End
  End

  It '削除数の省略で指定位置から末尾まで削除すること'
    sxtest_run myarr SX_SYS_REV -- 'sx_arr_gen myarr a b c'
    When call sx_arr_splice myarr 1
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal a
    The variable myarr_1 should be undefined
    The variable myarr_2 should be undefined
  End

  It '先頭から複数削除すると末尾の変数もすべて解放すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c
    When call sx_arr_splice myarr 0 2
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal "c"
    The variable myarr_1 should be undefined
    The variable myarr_2 should be undefined
  End

  It '全削除で空配列になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c
    When call sx_arr_splice myarr 0 3
    The status should be success
    The variable myarr_len should equal 0
    The variable myarr_0 should be undefined
    The variable myarr should start with "array-sx-sig-"
  End

  It 'n が長さを超える場合は開始位置までの距離を穴として保持すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 10 1 TAIL
    The status should be success
    The variable myarr_len should equal 11
    The variable myarr_2 should be undefined
    The variable myarr_9 should be undefined
    The variable myarr_10 should equal "TAIL"
  End

  It 'del が残りを超える場合は残り全部に丸めること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr 2 10 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "X"
    The variable myarr_3 should be undefined
  End

  It '空文字列や特殊文字を含む要素を扱えること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr "it's" 'say "hello"'
    When call sx_arr_splice myarr 1 1 ""
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "it's"
    The variable myarr_1 should equal ""
  End

  It '疎配列の穴を温存して移動すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c
    unset myarr_1
    sx_arr_splice myarr 0 0 HEAD
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should be undefined
    The variable myarr_3 should equal "c"
  End

  It '上書きされる要素の配列残骸を残さないこと'
    setup_command='
      SX_SYS_REV=$1
      sx_arr_gen myarr p q r
      sx_arr_gen myarr_1 s t
    '
    sxtest_run myarr myarr_1 SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
    When call sx_arr_splice myarr 0 2 X
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "r"
    The variable myarr_1_len should be undefined
    The variable myarr_1_0 should be undefined
  End

  It 'n が負の場合は len+n に換算すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr -1 1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c"
    The variable myarr_3 should equal "X"
  End

  It '先頭より前の穴を削除し、残った距離を保持すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr -10 1 HEAD
    The status should be success
    The variable myarr_len should equal 10
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should be undefined
    The variable myarr_7 should be undefined
    The variable myarr_8 should equal "a"
    The variable myarr_9 should equal "b"
  End

  It 'n が -len の場合は先頭になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr -4 1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "b"
  End

  It 'n が -0 の場合は先頭になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr -0 0 HEAD
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'n の先頭の + は除去されること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr +1 1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "c"
    The variable myarr_3 should equal "d"
  End

  It 'del が負の場合は残り長との和に丸めること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr 1 -1
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "d"
    The variable myarr_2 should be undefined
  End

  It 'del の絶対値が残り長と等しい場合は純挿入になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr 1 -3 HEAD
    The status should be success
    The variable myarr_len should equal 5
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "HEAD"
    The variable myarr_2 should equal "b"
    The variable myarr_3 should equal "c"
    The variable myarr_4 should equal "d"
  End

  It 'del の絶対値が残り長を超える場合は純挿入になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 -10 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'del が -0 の場合は純挿入になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 1 -0 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "b"
  End

  It 'del の先頭の + は除去されること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr 1 +1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "c"
    The variable myarr_3 should equal "d"
  End

  It 'del が +0 の場合は純挿入になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 1 +0 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "b"
  End

  It 'n が +0 の場合は先頭になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr +0 0 HEAD
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'n が先行0付きの場合は EX_USAGE を返すこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 01 1 X
    The status should equal 64
  End

  It 'n が -00 の場合は EX_USAGE を返すこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr -00 1 X
    The status should equal 64
  End

  It 'n が符号のみの場合は EX_USAGE を返すこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr + 1 X
    The status should equal 64
  End

  It 'n が --1 の場合は EX_USAGE を返すこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr --1 1 X
    The status should equal 64
  End

  It 'del が先行0付きの場合は EX_USAGE を返すこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 +01 X
    The status should equal 64
  End

  It 'del が -00 の場合は EX_USAGE を返すこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 -00 X
    The status should equal 64
  End

  It 'del が --1 の場合は EX_USAGE を返すこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 --1 X
    The status should equal 64
  End

  It 'n が長さを超える場合は del が負でも開始位置を保持すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 10 -5 TAIL
    The status should be success
    The variable myarr_len should equal 11
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should be undefined
    The variable myarr_9 should be undefined
    The variable myarr_10 should equal "TAIL"
  End

  It 'n が長さと等しい場合は del が負でも末尾追加になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 2 -1 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "TAIL"
  End

  It 'n と del が共に負の場合は換算後に削除すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr -3 -1
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "d"
    The variable myarr_2 should be undefined
  End

  It 'n と del が共に負の場合に挿入できること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr -2 -1 X Y
    The status should be success
    The variable myarr_len should equal 5
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "X"
    The variable myarr_3 should equal "Y"
    The variable myarr_4 should equal "d"
  End

  It '空配列で n が負の場合は末尾追加になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr
    When call sx_arr_splice myarr -1 0 X
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal "X"
  End

  It '空配列で del が負の場合は純挿入になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr
    When call sx_arr_splice myarr 0 -1 X
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal "X"
  End

  It 'n が巨大数でも穴の全添字を走査せず開始位置を保持すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 10000000000000000000000 0 TAIL
    The status should be success
    The variable myarr_len should equal 10000000000000000000001
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should be undefined
    The variable myarr_9999999999999999999999 should be undefined
    The variable myarr_10000000000000000000000 should equal "TAIL"
  End

  It '巨大な負の n でも旧範囲内だけを掃除し、残った距離を保持すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr -10000000000000000000000 1 HEAD
    The status should be success
    The variable myarr_len should equal 10000000000000000000000
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should be undefined
    The variable myarr_2 should be undefined
    The variable myarr_3 should be undefined
    The variable myarr_9999999999999999999995 should be undefined
    The variable myarr_9999999999999999999996 should equal "a"
    The variable myarr_9999999999999999999997 should equal "b"
    The variable myarr_9999999999999999999998 should equal "c"
    The variable myarr_9999999999999999999999 should equal "d"
  End

  It 'del の絶対値が巨大数の場合は純挿入になること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 -10000000000000000000000 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'n が整数でない場合は EX_USAGE を返すこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr x 1 X
    The status should equal 64
  End

  It 'del が整数でない場合は EX_USAGE を返すこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 y X
    The status should equal 64
  End

  It '対象が sx 配列でない場合に EX_DATAERR を返すこと'
    not_an_arr="val"
    When call sx_arr_splice not_an_arr 0 0 X
    The status should equal 65
  End

  It '配列の長さ変数が読み取り専用の場合に EX_NOPERM を返すこと'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c
    readonly myarr_len
    When call sx_arr_splice myarr 0 0 X
    The status should equal 77
  End

  It '設定エラー (EX_CONFIG: 78) を検知すること'
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    check_config() {
      SX_CFG_NUM_RANGE=99
      sx_arr_splice myarr 0 0 X
    }
    When call check_config
    The status should equal 78
  End

  Describe 'SX_CFG_SKIP_CHK モード'
    It 'checkskip 有効時も成功する'
      sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c
      SX_CFG_SKIP_CHK=1
      When call sx_arr_splice myarr 0 1 Z
      The status should be success
      The variable myarr_len should equal 3
      The variable myarr_0 should equal "Z"
      The variable myarr_1 should equal "b"
    End
  End

  Context '変数参照に見える文字列の挿入'
    Parameters
      '!myarr_2'
      '@myarr_2'
    End

    It '尾部の移動・削除にかかわらず指定した文字列を保存すること'
      sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; sx_arr_gen myarr a b c' "${SX_SYS_REV-0}"
      When call sx_arr_splice myarr 0 2 "$1"
      The status should be success
      The variable myarr_len should equal 2
      The variable myarr_0 should equal "$1"
      The variable myarr_1 should equal c
      The variable myarr_2 should be undefined
    End
  End

  It '文字列・空文字列・穴の混在でも各値が1位置を消費すること'
    src=reference
    sxtest_run myarr SX_CFG_ARR_HOLE SX_SYS_REV -- '
      SX_SYS_REV=$1
      sx_arr_gen myarr head old0 old1 old2 old3 tail
      sx_cfg_set ARR_HOLE=hole
    ' "${SX_SYS_REV-0}"
    When call sx_arr_splice myarr 1 4 '@src' '' hole '!src' literal
    The status should be success
    The variable myarr_len should equal 7
    The variable myarr_0 should equal head
    The variable myarr_1 should equal '@src'
    The variable myarr_2 should equal ''
    The variable myarr_3 should be undefined
    The variable myarr_4 should equal '!src'
    The variable myarr_5 should equal literal
    The variable myarr_6 should equal tail
  End
End
