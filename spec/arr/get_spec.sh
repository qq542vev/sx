#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_get'
  Include ./sx.sh
  BeforeEach 'sx_arr_gen myarr "a" "b" "c" "d" "e"'

  Context '単体指定'
    It '先頭要素を取得できること'
      When call sx_arr_get x myarr 0
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "a"
    End

    It '複数指定は順序保持で取得できること'
      When call sx_arr_get x myarr 0 3
      The status should be success
      The variable x_len should equal 2
      The variable x_0 should equal "a"
      The variable x_1 should equal "d"
    End

    It '逆順指定も順序保持で取得できること'
      When call sx_arr_get x myarr 4 2
      The status should be success
      The variable x_len should equal 2
      The variable x_0 should equal "e"
      The variable x_1 should equal "c"
    End

    It '範囲外の単体はスキップして空配列で成功すること'
      When call sx_arr_get x myarr 6
      The status should be success
      The variable x_len should equal 0
    End

    It '範囲外を混ぜても有効分だけ取得できること'
      When call sx_arr_get x myarr 3 6 1
      The status should be success
      The variable x_len should equal 2
      The variable x_0 should equal "d"
      The variable x_1 should equal "b"
    End

    It '負数は後ろから換算されること (1 と -4 は等価)'
      When call sx_arr_get x myarr -4
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "b"
    End

    It '負数の複数指定ができること'
      When call sx_arr_get x myarr -1 -3
      The status should be success
      The variable x_len should equal 2
      The variable x_0 should equal "e"
      The variable x_1 should equal "c"
    End

    It '換算後も範囲外の負数は空であること'
      When call sx_arr_get x myarr -6
      The status should be success
      The variable x_len should equal 0
    End

    It '-len は先頭要素を示すこと'
      When call sx_arr_get x myarr -5
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "a"
    End

    It '-0 は 0 とみなすこと'
      When call sx_arr_get x myarr -0
      The status should be success
      The variable x_0 should equal "a"
    End

    It '+接頭辞を許すこと'
      When call sx_arr_get x myarr +1
      The status should be success
      The variable x_0 should equal "b"
    End
  End

  Context '範囲指定 (半開区間)'
    It '前方範囲と単体の混在ができること'
      When call sx_arr_get x myarr 0:3 4
      The status should be success
      The variable x_len should equal 4
      The variable x_0 should equal "a"
      The variable x_1 should equal "b"
      The variable x_2 should equal "c"
      The variable x_3 should equal "e"
    End

    It '始点と終点が等しい範囲は空であること'
      When call sx_arr_get x myarr 2:2
      The status should be success
      The variable x_len should equal 0
    End

    It '逆方向の2要素範囲は既定step=1では空であること (range互換)'
      When call sx_arr_get x myarr 3:0
      The status should be success
      The variable x_len should equal 0
    End

    It '逆方向範囲は負stepで降順に排出すること (t<0 は終端を含む)'
      When call sx_arr_get x myarr 3:0:-1
      The status should be success
      The variable x_len should equal 4
      The variable x_0 should equal "d"
      The variable x_1 should equal "c"
      The variable x_2 should equal "b"
      The variable x_3 should equal "a"
    End

    It '負端点の範囲ができること (1:3 と -4:-2 は等価)'
      When call sx_arr_get x myarr -4:-2
      The status should be success
      The variable x_len should equal 2
      The variable x_0 should equal "b"
      The variable x_1 should equal "c"
    End

    It '正と負を混ぜた範囲ができること'
      When call sx_arr_get x myarr 1:-1
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "b"
      The variable x_1 should equal "c"
      The variable x_2 should equal "d"
    End

    It '逆方向の正負混在範囲は既定step=1では空であること (range互換)'
      When call sx_arr_get x myarr -1:1
      The status should be success
      The variable x_len should equal 0
    End

    It '逆方向の正負混在範囲は負stepで排出できること (t<0 は終端を含む)'
      When call sx_arr_get x myarr -1:1:-1
      The status should be success
      The variable x_len should equal 4
      The variable x_0 should equal "e"
      The variable x_1 should equal "d"
      The variable x_2 should equal "c"
      The variable x_3 should equal "b"
    End

    It '両端が範囲外の範囲は空であること'
      When call sx_arr_get x myarr 6:10
      The status should be success
      The variable x_len should equal 0
    End

    It '換算後も範囲外の両端は 0 に丸めること'
      When call sx_arr_get x myarr -10:-8
      The status should be success
      The variable x_len should equal 0
    End

    It '下側超過の端点は 0 に丸めること'
      When call sx_arr_get x myarr -10:1
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "a"
    End

    It '上側超過の両端は空であること'
      When call sx_arr_get x myarr 400:500
      The status should be success
      The variable x_len should equal 0
    End

    It '上側超過の始点は既定step=1では空であること (range互換)'
      When call sx_arr_get x myarr 400:1
      The status should be success
      The variable x_len should equal 0
    End

    It '上側超過の始点は負stepで len-1 から開始すること (t<0 は終端を含む)'
      When call sx_arr_get x myarr 400:1:-1
      The status should be success
      The variable x_len should equal 4
      The variable x_0 should equal "e"
      The variable x_1 should equal "d"
      The variable x_2 should equal "c"
      The variable x_3 should equal "b"
    End

    It '終端 len は全件となること'
      When call sx_arr_get x myarr 0:5
      The status should be success
      The variable x_len should equal 5
      The variable x_4 should equal "e"
    End

    It '逆方向の全件は既定step=1では空であること (range互換)'
      When call sx_arr_get x myarr 5:0
      The status should be success
      The variable x_len should equal 0
    End

    It '逆方向の全件は負stepで len-1 から開始すること (t<0 は終端を含む)'
      When call sx_arr_get x myarr 5:0:-1
      The status should be success
      The variable x_len should equal 5
      The variable x_0 should equal "e"
      The variable x_1 should equal "d"
      The variable x_2 should equal "c"
      The variable x_3 should equal "b"
      The variable x_4 should equal "a"
    End
  End

  Context 'step指定 (range互換)'
    It '正stepで間引いて取得できること'
      When call sx_arr_get x myarr 0:5:2
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "a"
      The variable x_1 should equal "c"
      The variable x_2 should equal "e"
    End

    It '負stepで間引いて取得できること (t<0 は終端を含む)'
      When call sx_arr_get x myarr 4:0:-2
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "e"
      The variable x_1 should equal "c"
      The variable x_2 should equal "a"
    End

    It '範囲内に収まる大きなstepは先頭のみ取得すること'
      When call sx_arr_get x myarr 1:2:3
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "b"
    End

    It '方向とstepの符号が逆の範囲は空であること'
      When call sx_arr_get x myarr 0:5:-1
      The status should be success
      The variable x_len should equal 0
    End

    It '空配列のstep範囲も空配列で成功すること'
      sx_arr_gen empty_arr
      When call sx_arr_get x empty_arr 0:5:2
      The status should be success
      The variable x_len should equal 0
    End
  End

  Context '分配と空'
    It '分配形式へ順序通り分配できること'
      When call sx_arr_get 2a:x myarr 0:3 4
      The status should be success
      The variable a_len should equal 2
      The variable a_0 should equal "a"
      The variable a_1 should equal "b"
      The variable x_len should equal 2
      The variable x_0 should equal "c"
      The variable x_1 should equal "e"
    End

    It 'spec なしは空配列で成功すること'
      When call sx_arr_get x myarr
      The status should be success
      The variable x_len should equal 0
    End

    It '空配列からは空配列で成功すること'
      sx_arr_gen empty_arr
      When call sx_arr_get x empty_arr 0
      The status should be success
      The variable x_len should equal 0
    End

    It '空配列の-0も空配列で成功すること (ガード経路)'
      sx_arr_gen empty_arr
      When call sx_arr_get x empty_arr -0
      The status should be success
      The variable x_len should equal 0
    End

    It '空配列の範囲も空配列で成功すること'
      sx_arr_gen empty_arr
      When call sx_arr_get x empty_arr 0:5
      The status should be success
      The variable x_len should equal 0
    End

    It '空配列の省略終端も空配列で成功すること'
      sx_arr_gen empty_arr
      When call sx_arr_get x empty_arr 0:-5:-1 2::-1
      The status should be success
      The variable x_len should equal 0
    End
  End

  Context '終端省略と正確位相'
    It 's: は末尾まで取得できること'
      When call sx_arr_get x myarr 2:
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "c"
      The variable x_2 should equal "e"
    End

    It 's::t は末尾まで間引いて取得できること'
      When call sx_arr_get x myarr 1::2
      The status should be success
      The variable x_len should equal 2
      The variable x_0 should equal "b"
      The variable x_1 should equal "d"
    End

    It 's::-1 は先頭まで降順に取得できること'
      When call sx_arr_get x myarr 2::-1
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "c"
      The variable x_1 should equal "b"
      The variable x_2 should equal "a"
    End

    It '負始点の刻みは位相を保持すること (-6:5:2 は b,d)'
      When call sx_arr_get x myarr -6:5:2
      The status should be success
      The variable x_len should equal 2
      The variable x_0 should equal "b"
      The variable x_1 should equal "d"
    End

    It '上側超過の始点は負stepで len-1 から開始すること (5::-2 は d,b)'
      When call sx_arr_get x myarr 5::-2
      The status should be success
      The variable x_len should equal 2
      The variable x_0 should equal "d"
      The variable x_1 should equal "b"
    End

    It '負終端超過の降順は先頭まで含むこと (4:-99:-1 は全件)'
      When call sx_arr_get x myarr 4:-99:-1
      The status should be success
      The variable x_len should equal 5
      The variable x_0 should equal "e"
      The variable x_4 should equal "a"
    End

    It '5:3:-2 は d のみ取得すること (t<0 は終端を含む)'
      When call sx_arr_get x myarr 5:3:-2
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "d"
    End

    It '巨大な負始点も正確に解決すること'
      When call sx_arr_get x myarr -100000000000000000000000:5:1
      The status should be success
      The variable x_len should equal 5
      The variable x_0 should equal "a"
    End

    It '巨大な正始点の降順も正確に解決すること (t<0 は終端を含む)'
      When call sx_arr_get x myarr 99999999999999999999999:1:-1
      The status should be success
      The variable x_len should equal 4
      The variable x_0 should equal "e"
      The variable x_2 should equal "c"
      The variable x_3 should equal "b"
    End

    It '巨大な刻みでも先頭のみ取得すること'
      When call sx_arr_get x myarr 0:5:100000000000000000000000
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "a"
    End

    It '最小値の刻みでも動作すること'
      When call sx_arr_get x myarr 4:0:-2147483648
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "e"
    End

    It '巨大な終端でも末尾要素のみ取得すること'
      When call sx_arr_get x myarr 4:100000000000000000000000:1
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "e"
    End

    It '巨大な始点の単一命中も正確に解決すること'
      When call sx_arr_get x myarr 99999999999999999999999:4:-1
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "e"
    End
  End

  Context '始点省略'
    It ':e は先頭から取得できること'
      When call sx_arr_get x myarr :3
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "a"
      The variable x_2 should equal "c"
    End

    It '::t は全件を間引いて取得できること'
      When call sx_arr_get x myarr ::2
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "a"
      The variable x_2 should equal "e"
    End

    It '::-t は全件を逆順に取得できること'
      When call sx_arr_get x myarr ::-1
      The status should be success
      The variable x_len should equal 5
      The variable x_0 should equal "e"
      The variable x_4 should equal "a"
    End

    It ':e:-t は逆半開区間として取得できること'
      When call sx_arr_get x myarr :0:-1
      The status should be success
      The variable x_len should equal 5
      The variable x_0 should equal "e"
      The variable x_4 should equal "a"
    End

    It ':e:-t は逆半開区間として取得できること'
      When call sx_arr_get x myarr :0:-1
      The status should be success
      The variable x_len should equal 5
      The variable x_0 should equal "e"
      The variable x_4 should equal "a"
    End

    It 's==e の負stepは単要素を取得すること'
      When call sx_arr_get x myarr 2:2:-1
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "c"
    End

    It 's:e:-t の終端を含むこと (5:2:-1 は e,d,c)'
      When call sx_arr_get x myarr 5:2:-1
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "e"
      The variable x_1 should equal "d"
      The variable x_2 should equal "c"
    End
  End

  Context '異常系・エラーハンドリング'
    It '- 区切りは引数不正で 64 を返すこと'
      When call sx_arr_get x myarr 1-2
      The status should equal 64
    End

    It '-- を含む形式は 64 を返すこと'
      When call sx_arr_get x myarr -4--2
      The status should equal 64
    End

    It '端点なしの : は全件取得すること'
      When call sx_arr_get x myarr :
      The status should be success
      The variable x_len should equal 5
      The variable x_0 should equal "a"
      The variable x_4 should equal "e"
    End

    It '空の刻みは 64 を返すこと'
      When call sx_arr_get x myarr 1:2: 2::
      The status should equal 64
    End

    It '旧記法 ~ は引数不正で 64 を返すこと'
      When call sx_arr_get x myarr 0~3
      The status should equal 64
    End

    It '旧記法 ~ 単体は 64 を返すこと'
      When call sx_arr_get x myarr ~
      The status should equal 64
    End

    It 'stepが0の範囲は 64 を返すこと'
      When call sx_arr_get x myarr 0:5:0
      The status should equal 64
    End

    It 'stepが-0の範囲は 64 を返すこと'
      When call sx_arr_get x myarr 0:5:-0
      The status should equal 64
    End

    It 'stepが+0の範囲は 64 を返すこと'
      When call sx_arr_get x myarr 0:5:+0
      The status should equal 64
    End

    It '4要素 (:が3つ) は 64 を返すこと'
      When call sx_arr_get x myarr 1:2:3:4
      The status should equal 64
    End

    It '数値でない spec は 64 を返すこと'
      When call sx_arr_get x myarr abc
      The status should equal 64
    End

    It '前ゼロ付きは 64 を返すこと'
      When call sx_arr_get x myarr 007
      The status should equal 64
    End

    It '配列ではない変数に 65 を返すこと'
      not_arr="not an array"
      When call sx_arr_get x not_arr 0
      The status should equal 65
    End

    It 'バインド形式不正に 64 を返すこと'
      When call sx_arr_get "2b" myarr 0
      The status should equal 64
    End

    It '結果変数が読み取り専用の場合は 77 を返すこと'
      readonly ro_var
      When call sx_arr_get ro_var myarr 0
      The status should equal 77
    End

    It '設定エラー (EX_CONFIG: 78) を検知すること'
      check_config() {
        SX_CFG_NUM_RANGE=99
        sx_arr_get x myarr 0
      }

      When call check_config
      The status should equal 78
    End
  End

  Context '高速化モード (SX_CFG_SKIP_CHK=1)'
    It 'スキップモードでも範囲取得できること'
      SX_CFG_SKIP_CHK=1
      When call sx_arr_get x myarr 1:3
      The variable x_0 should equal "b"
      The variable x_1 should equal "c"
      The status should be success
    End

    It 'スキップモードでも範囲外単体をスキップすること'
      SX_CFG_SKIP_CHK=1
      When call sx_arr_get x myarr 6
      The status should be success
      The variable x_len should equal 0
    End
  End

  Context '算術域境界 (NUM_RANGE=64)'
    arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }
    Before 'sx_cfg_set NUM_RANGE=64'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64

    It 't<0 クランプの中間値が溢れないこと (始点D・step-5・境界)'
      When call sx_arr_get x myarr 9223372036854775807:0:-5
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "c"
    End

    It 't<0 クランプの中間値が溢れないこと (始点D・step-6)'
      When call sx_arr_get x myarr 9223372036854775807:0:-6
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "b"
    End

    It 't<0 クランプ境界 (|t|=4) は溢れずに解決すること'
      When call sx_arr_get x myarr 9223372036854775807:0:-4
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "d"
    End

    It '開始値が算術最小値でも正規化が溢れず全件を解決すること'
      When call sx_arr_get x myarr -9223372036854775813:10:1
      The status should be success
      The variable x_len should equal 5
      The variable x_0 should equal "a"
      The variable x_4 should equal "e"
    End

    It '負始点と巨大正stepの正規化が溢れず空で終えること'
      When call sx_arr_get x myarr -9000000000000000000:10:9000000000000000000
      The status should be success
      The variable x_len should equal 0
    End

    It '多倍長減算の結果が短い正数になる範囲を取得できること'
      When call sx_arr_get x myarr -9223372036854775809:5:+9223372036854775808
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "e"
    End
  End
End
