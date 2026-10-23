#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_splice'
  Include ./spec/support/setup.sh
  Include ./spec/support/library.sh sx_arr_splice

  It '中間の要素を置換すること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen myarr "$@"' "${SX_SYS_REV-0}" a b c d
    When call sx_arr_splice myarr 1 2 X Y
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "Y"
    The variable myarr_3 should equal "d"
  End

  It '先頭に挿入すること (del=0)'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr b c
    When call sx_arr_splice myarr 0 0 HEAD
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c"
  End

  It '末尾に挿入すること (n=len)'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 2 0 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_2 should equal "TAIL"
  End

  It '値なしで純削除すること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c
    When call sx_arr_splice myarr 1 1
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "c"
    The variable myarr_2 should be undefined
  End

  It '全削除で空配列になること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c
    When call sx_arr_splice myarr 0 3
    The status should be success
    The variable myarr_len should equal 0
    The variable myarr_0 should be undefined
    The variable myarr should start with "array-sx-sig-"
  End

  It 'n が長さを超える場合は末尾扱いに丸めること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 10 1 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_2 should equal "TAIL"
  End

  It 'del が残りを超える場合は残り全部に丸めること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr 2 10 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "X"
    The variable myarr_3 should be undefined
  End

  It '空文字列や特殊文字を含む要素を扱えること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr "it's" 'say "hello"'
    When call sx_arr_splice myarr 1 1 ""
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "it's"
    The variable myarr_1 should equal ""
  End

  It '疎配列の穴を温存して移動すること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c
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
    sxtest_setup myarr myarr_1 SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
    When call sx_arr_splice myarr 0 2 X
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "r"
    The variable myarr_1_len should be undefined
    The variable myarr_1_0 should be undefined
  End

  It 'n が負の場合は len+n に換算すること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr -1 1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c"
    The variable myarr_3 should equal "X"
  End

  It 'n の絶対値が長さを超える場合は先頭扱いに丸めること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr -10 1 HEAD
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "b"
  End

  It 'n が -len の場合は先頭になること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr -4 1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "b"
  End

  It 'n が -0 の場合は先頭になること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr -0 0 HEAD
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'n の先頭の + は除去されること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr +1 1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "c"
    The variable myarr_3 should equal "d"
  End

  It 'del が負の場合は残り長との和に丸めること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr 1 -1
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "d"
    The variable myarr_2 should be undefined
  End

  It 'del の絶対値が残り長と等しい場合は純挿入になること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
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
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 -10 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'del が -0 の場合は純挿入になること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 1 -0 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "b"
  End

  It 'del の先頭の + は除去されること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr 1 +1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "c"
    The variable myarr_3 should equal "d"
  End

  It 'del が +0 の場合は純挿入になること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 1 +0 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "b"
  End

  It 'n が +0 の場合は先頭になること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr +0 0 HEAD
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'n が先行0付きの場合は EX_USAGE を返すこと'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 01 1 X
    The status should equal 64
  End

  It 'n が -00 の場合は EX_USAGE を返すこと'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr -00 1 X
    The status should equal 64
  End

  It 'n が符号のみの場合は EX_USAGE を返すこと'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr + 1 X
    The status should equal 64
  End

  It 'n が --1 の場合は EX_USAGE を返すこと'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr --1 1 X
    The status should equal 64
  End

  It 'del が先行0付きの場合は EX_USAGE を返すこと'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 +01 X
    The status should equal 64
  End

  It 'del が -00 の場合は EX_USAGE を返すこと'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 -00 X
    The status should equal 64
  End

  It 'del が --1 の場合は EX_USAGE を返すこと'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 --1 X
    The status should equal 64
  End

  It 'n が長さを超える場合は del が負でも末尾追加になること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 10 -5 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "TAIL"
  End

  It 'n が長さと等しい場合は del が負でも末尾追加になること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 2 -1 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "TAIL"
  End

  It 'n と del が共に負の場合は換算後に削除すること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr -3 -1
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "d"
    The variable myarr_2 should be undefined
  End

  It 'n と del が共に負の場合に挿入できること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
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
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr
    When call sx_arr_splice myarr -1 0 X
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal "X"
  End

  It '空配列で del が負の場合は純挿入になること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr
    When call sx_arr_splice myarr 0 -1 X
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal "X"
  End

  It 'n が巨大数の場合は末尾扱いに丸めること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 10000000000000000000000 0 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "TAIL"
  End

  It 'n の絶対値が巨大数の場合は先頭扱いに丸めること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c d
    When call sx_arr_splice myarr -10000000000000000000000 1 HEAD
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c"
    The variable myarr_3 should equal "d"
  End

  It 'del の絶対値が巨大数の場合は純挿入になること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 -10000000000000000000000 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'n が整数でない場合は EX_USAGE を返すこと'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr x 1 X
    The status should equal 64
  End

  It 'del が整数でない場合は EX_USAGE を返すこと'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    When call sx_arr_splice myarr 0 y X
    The status should equal 64
  End

  It '対象が sx 配列でない場合に EX_DATAERR を返すこと'
    not_an_arr="val"
    When call sx_arr_splice not_an_arr 0 0 X
    The status should equal 65
  End

  It '配列の長さ変数が読み取り専用の場合に EX_NOPERM を返すこと'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c
    readonly myarr_len
    When call sx_arr_splice myarr 0 0 X
    The status should equal 77
  End

  It '設定エラー (EX_CONFIG: 78) を検知すること'
    sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b
    check_config() {
      SX_CFG_NUM_RANGE=99
      sx_arr_splice myarr 0 0 X
    }
    When call check_config
    The status should equal 78
  End

  Describe 'SX_CFG_SKIP_CHK モード'
    It 'checkskip 有効時も成功する'
      sxtest_setup myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a b c
      SX_CFG_SKIP_CHK=1
      When call sx_arr_splice myarr 0 1 Z
      The status should be success
      The variable myarr_len should equal 3
      The variable myarr_0 should equal "Z"
      The variable myarr_1 should equal "b"
    End
  End

  Describe 'SX_CFG_ARR_REF'
    It '参照値の後のリテラルを次の位置に挿入すること'
      src="reference"
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen myarr head tail
        sx_cfg_set "ARR_REF=@"
      '
      sxtest_setup myarr SX_CFG_ARR_REF SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      When call sx_arr_splice myarr 1 0 "@src" literal
      The status should be success
      The variable myarr_len should equal 4
      The variable myarr_0 should equal "head"
      The variable myarr_1 should equal "reference"
      The variable myarr_2 should equal "literal"
      The variable myarr_3 should equal "tail"
      sxtest_setup SX_CFG_ARR_REF -- 'sx_cfg_set "$@"' "ARR_REF"
      sxtest_setup myarr myarr_len myarr_0 myarr_1 myarr_2 myarr_3 src -- \
        'sx_var_unset "$@"' myarr myarr_len myarr_0 myarr_1 myarr_2 myarr_3 src
    End

    It '参照値・空文字列・穴の混在でも各値が1位置を消費すること'
      src="reference"
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen myarr head old0 old1 old2 old3 tail
        sx_cfg_set "ARR_REF=@" "ARR_HOLE=hole"
      '
      sxtest_setup myarr SX_CFG_ARR_REF SX_CFG_ARR_HOLE SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      When call sx_arr_splice myarr 1 4 "@src" "" hole "@src" literal
      The status should be success
      The variable myarr_len should equal 7
      The variable myarr_0 should equal "head"
      The variable myarr_1 should equal "reference"
      The variable myarr_2 should equal ""
      The variable myarr_3 should be undefined
      The variable myarr_4 should equal "reference"
      The variable myarr_5 should equal "literal"
      The variable myarr_6 should equal "tail"
      sxtest_setup SX_CFG_ARR_REF SX_CFG_ARR_HOLE -- 'sx_cfg_set "$@"' "ARR_REF" "ARR_HOLE"
      sxtest_setup myarr myarr_len myarr_0 myarr_1 myarr_2 myarr_3 myarr_4 myarr_5 myarr_6 src -- \
        'sx_var_unset "$@"' myarr myarr_len myarr_0 myarr_1 myarr_2 myarr_3 myarr_4 myarr_5 myarr_6 src
    End

    It '参照形式（@名前）は変数の値をコピーすること'
      src="hello"
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen myarr a b
        sx_cfg_set "ARR_REF=@"
      '
      sxtest_setup myarr SX_CFG_ARR_REF SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      When call sx_arr_splice myarr 1 0 "@src"
      The status should be success
      The variable myarr_len should equal 3
      The variable myarr_1 should equal "hello"
      sxtest_setup SX_CFG_ARR_REF -- 'sx_cfg_set "$@"' "ARR_REF"
      sxtest_setup myarr myarr_len myarr_0 myarr_1 myarr_2 src -- \
        'sx_var_unset "$@"' myarr myarr_len myarr_0 myarr_1 myarr_2 src
    End

    It '参照先が変数名でない場合はリテラル扱いになること'
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen myarr2 x
        sx_cfg_set "ARR_REF=@"
      '
      sxtest_setup myarr2 SX_CFG_ARR_REF SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      When call sx_arr_splice myarr2 1 0 "@123"
      The status should be success
      The variable myarr2_1 should equal "@123"
      sxtest_setup SX_CFG_ARR_REF -- 'sx_cfg_set "$@"' "ARR_REF"
      sxtest_setup myarr2 myarr2_len myarr2_0 myarr2_1 -- \
        'sx_var_unset "$@"' myarr2 myarr2_len myarr2_0 myarr2_1
    End

    It 'ARR_REF が空の場合は参照せずリテラル扱いになること'
      src="hello"
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen myarr3 x
        sx_cfg_set "ARR_REF"
      '
      sxtest_setup myarr3 SX_CFG_ARR_REF SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      When call sx_arr_splice myarr3 1 0 "@src"
      The status should be success
      The variable myarr3_1 should equal "@src"
      sxtest_setup myarr3 myarr3_len myarr3_0 myarr3_1 src -- \
        'sx_var_unset "$@"' myarr3 myarr3_len myarr3_0 myarr3_1 src
    End
  End
End
