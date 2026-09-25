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

    It '換算後も範囲外の負数は 0 に丸めること'
      When call sx_arr_get x myarr -6
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "a"
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
      When call sx_arr_get x myarr 0~3 4
      The status should be success
      The variable x_len should equal 4
      The variable x_0 should equal "a"
      The variable x_1 should equal "b"
      The variable x_2 should equal "c"
      The variable x_3 should equal "e"
    End

    It '始点と終点が等しい範囲は空であること'
      When call sx_arr_get x myarr 2~2
      The status should be success
      The variable x_len should equal 0
    End

    It '逆方向範囲は降順で排出すること'
      When call sx_arr_get x myarr 3~0
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "c"
      The variable x_1 should equal "b"
      The variable x_2 should equal "a"
    End

    It '負端点の範囲ができること (1~3 と -4~-2 は等価)'
      When call sx_arr_get x myarr -4~-2
      The status should be success
      The variable x_len should equal 2
      The variable x_0 should equal "b"
      The variable x_1 should equal "c"
    End

    It '正と負を混ぜた範囲ができること'
      When call sx_arr_get x myarr 1~-1
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "b"
      The variable x_1 should equal "c"
      The variable x_2 should equal "d"
    End

    It '逆方向の正負混在範囲ができること'
      When call sx_arr_get x myarr -1~1
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "d"
      The variable x_1 should equal "c"
      The variable x_2 should equal "b"
    End

    It '両端が範囲外の範囲は空であること'
      When call sx_arr_get x myarr 6~10
      The status should be success
      The variable x_len should equal 0
    End

    It '換算後も範囲外の両端は 0 に丸めること'
      When call sx_arr_get x myarr -10~-8
      The status should be success
      The variable x_len should equal 0
    End

    It '下側超過の端点は 0 に丸めること'
      When call sx_arr_get x myarr -10~1
      The status should be success
      The variable x_len should equal 1
      The variable x_0 should equal "a"
    End

    It '上側超過の両端は空であること'
      When call sx_arr_get x myarr 400~500
      The status should be success
      The variable x_len should equal 0
    End

    It '上側超過の始点は len に丸めること'
      When call sx_arr_get x myarr 400~1
      The status should be success
      The variable x_len should equal 4
      The variable x_0 should equal "e"
      The variable x_1 should equal "d"
      The variable x_2 should equal "c"
      The variable x_3 should equal "b"
    End

    It '終端 len は全件となること'
      When call sx_arr_get x myarr 0~5
      The status should be success
      The variable x_len should equal 5
      The variable x_4 should equal "e"
    End

    It '逆方向の全件ができること'
      When call sx_arr_get x myarr 5~0
      The status should be success
      The variable x_len should equal 5
      The variable x_0 should equal "e"
      The variable x_4 should equal "a"
    End
  End

  Context '分配と空'
    It '分配形式へ順序通り分配できること'
      When call sx_arr_get 2a:x myarr 0~3 4
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

    It '空配列の範囲も空配列で成功すること'
      sx_arr_gen empty_arr
      When call sx_arr_get x empty_arr 0~5
      The status should be success
      The variable x_len should equal 0
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

    It '端点なしの ~ は 64 を返すこと'
      When call sx_arr_get x myarr ~
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
      When call sx_arr_get x myarr 1~3
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
End
