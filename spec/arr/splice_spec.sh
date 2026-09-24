#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_splice'
  Include ./sx.sh

  It '中間の要素を置換すること'
    sx_arr_gen myarr a b c d
    When call sx_arr_splice myarr 1 2 X Y
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "Y"
    The variable myarr_3 should equal "d"
  End

  It '先頭に挿入すること (del=0)'
    sx_arr_gen myarr b c
    When call sx_arr_splice myarr 0 0 HEAD
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c"
  End

  It '末尾に挿入すること (n=len)'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 2 0 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_2 should equal "TAIL"
  End

  It '値なしで純削除すること'
    sx_arr_gen myarr a b c
    When call sx_arr_splice myarr 1 1
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "c"
    The variable myarr_2 should be undefined
  End

  It '全削除で空配列になること'
    sx_arr_gen myarr a b c
    When call sx_arr_splice myarr 0 3
    The status should be success
    The variable myarr_len should equal 0
    The variable myarr_0 should be undefined
    The variable myarr should start with "array-sx-sig-"
  End

  It 'n が長さを超える場合は末尾扱いに丸めること'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 10 1 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_2 should equal "TAIL"
  End

  It 'del が残りを超える場合は残り全部に丸めること'
    sx_arr_gen myarr a b c d
    When call sx_arr_splice myarr 2 10 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "X"
    The variable myarr_3 should be undefined
  End

  It '空文字列や特殊文字を含む要素を扱えること'
    sx_arr_gen myarr "it's" 'say "hello"'
    When call sx_arr_splice myarr 1 1 ""
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "it's"
    The variable myarr_1 should equal ""
  End

  It '疎配列の穴を温存して移動すること'
    sx_arr_gen myarr a b c
    unset myarr_1
    sx_arr_splice myarr 0 0 HEAD
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should be undefined
    The variable myarr_3 should equal "c"
  End

  It '上書きされる要素の配列残骸を残さないこと'
    sx_arr_gen myarr p q r
    sx_arr_gen myarr_1 s t
    When call sx_arr_splice myarr 0 2 X
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "r"
    The variable myarr_1_len should be undefined
    The variable myarr_1_0 should be undefined
  End

  It 'n が負の場合は len+n に換算すること'
    sx_arr_gen myarr a b c d
    When call sx_arr_splice myarr -1 1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c"
    The variable myarr_3 should equal "X"
  End

  It 'n の絶対値が長さを超える場合は先頭扱いに丸めること'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr -10 1 HEAD
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "b"
  End

  It 'n が -len の場合は先頭になること'
    sx_arr_gen myarr a b c d
    When call sx_arr_splice myarr -4 1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "b"
  End

  It 'n が -0 の場合は先頭になること'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr -0 0 HEAD
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'n の先頭の + は除去されること'
    sx_arr_gen myarr a b c d
    When call sx_arr_splice myarr +1 1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "c"
    The variable myarr_3 should equal "d"
  End

  It 'del が負の場合は残り長との和に丸めること'
    sx_arr_gen myarr a b c d
    When call sx_arr_splice myarr 1 -1
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "d"
    The variable myarr_2 should be undefined
  End

  It 'del の絶対値が残り長と等しい場合は純挿入になること'
    sx_arr_gen myarr a b c d
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
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 0 -10 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'del が -0 の場合は純挿入になること'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 1 -0 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "b"
  End

  It 'del の先頭の + は除去されること'
    sx_arr_gen myarr a b c d
    When call sx_arr_splice myarr 1 +1 X
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "c"
    The variable myarr_3 should equal "d"
  End

  It 'del が +0 の場合は純挿入になること'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 1 +0 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "X"
    The variable myarr_2 should equal "b"
  End

  It 'n が +0 の場合は先頭になること'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr +0 0 HEAD
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'n が先行0付きの場合は EX_USAGE を返すこと'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 01 1 X
    The status should equal 64
  End

  It 'n が -00 の場合は EX_USAGE を返すこと'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr -00 1 X
    The status should equal 64
  End

  It 'n が符号のみの場合は EX_USAGE を返すこと'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr + 1 X
    The status should equal 64
  End

  It 'n が --1 の場合は EX_USAGE を返すこと'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr --1 1 X
    The status should equal 64
  End

  It 'del が先行0付きの場合は EX_USAGE を返すこと'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 0 +01 X
    The status should equal 64
  End

  It 'del が -00 の場合は EX_USAGE を返すこと'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 0 -00 X
    The status should equal 64
  End

  It 'del が --1 の場合は EX_USAGE を返すこと'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 0 --1 X
    The status should equal 64
  End

  It 'n が長さを超える場合は del が負でも末尾追加になること'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 10 -5 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "TAIL"
  End

  It 'n が長さと等しい場合は del が負でも末尾追加になること'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 2 -1 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "TAIL"
  End

  It 'n と del が共に負の場合は換算後に削除すること'
    sx_arr_gen myarr a b c d
    When call sx_arr_splice myarr -3 -1
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "d"
    The variable myarr_2 should be undefined
  End

  It 'n と del が共に負の場合に挿入できること'
    sx_arr_gen myarr a b c d
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
    sx_arr_gen myarr
    When call sx_arr_splice myarr -1 0 X
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal "X"
  End

  It '空配列で del が負の場合は純挿入になること'
    sx_arr_gen myarr
    When call sx_arr_splice myarr 0 -1 X
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal "X"
  End

  It 'n が巨大数の場合は末尾扱いに丸めること'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 10000000000000000000000 0 TAIL
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "TAIL"
  End

  It 'n の絶対値が巨大数の場合は先頭扱いに丸めること'
    sx_arr_gen myarr a b c d
    When call sx_arr_splice myarr -10000000000000000000000 1 HEAD
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "HEAD"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c"
    The variable myarr_3 should equal "d"
  End

  It 'del の絶対値が巨大数の場合は純挿入になること'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 0 -10000000000000000000000 X
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "X"
    The variable myarr_1 should equal "a"
    The variable myarr_2 should equal "b"
  End

  It 'n が整数でない場合は EX_USAGE を返すこと'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr x 1 X
    The status should equal 64
  End

  It 'del が整数でない場合は EX_USAGE を返すこと'
    sx_arr_gen myarr a b
    When call sx_arr_splice myarr 0 y X
    The status should equal 64
  End

  It '対象が sx 配列でない場合に EX_DATAERR を返すこと'
    not_an_arr="val"
    When call sx_arr_splice not_an_arr 0 0 X
    The status should equal 65
  End

  It '配列の長さ変数が読み取り専用の場合に EX_NOPERM を返すこと'
    sx_arr_gen myarr a b c
    readonly myarr_len
    When call sx_arr_splice myarr 0 0 X
    The status should equal 77
  End

  It '設定エラー (EX_CONFIG: 78) を検知すること'
    sx_arr_gen myarr a b
    check_config() {
      SX_CFG_NUM_RANGE=99
      sx_arr_splice myarr 0 0 X
    }
    When call check_config
    The status should equal 78
  End

  Describe 'SX_CFG_SKIP_CHK モード'
    It 'checkskip 有効時も成功する'
      sx_arr_gen myarr a b c
      SX_CFG_SKIP_CHK=1
      When call sx_arr_splice myarr 0 1 Z
      The status should be success
      The variable myarr_len should equal 3
      The variable myarr_0 should equal "Z"
      The variable myarr_1 should equal "b"
    End
  End
End
