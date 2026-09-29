#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_has'
  Include ./sx.sh
  BeforeEach 'sx_arr_gen myarr "a" "b" "c" "d" "e"'

  Context '単体指定 (any 意味論)'
    It '存在するインデックスに対して成功を返すこと'
      When call sx_arr_has myarr 0
      The status should be success
    End

    It '末尾のインデックスに対して成功を返すこと'
      When call sx_arr_has myarr 4
      The status should be success
    End

    It '長さに等しい単体は空として失敗を返すこと'
      When call sx_arr_has myarr 5
      The status should be failure
    End

    It '範囲外の単体は空として失敗を返すこと'
      When call sx_arr_has myarr 9
      The status should be failure
    End

    It '負数は後ろから換算されること (-1 は末尾に一致)'
      When call sx_arr_has myarr -1
      The status should be success
    End

    It '-len は先頭要素に一致すること'
      When call sx_arr_has myarr -5
      The status should be success
    End

    It '換算後も範囲外の負数は空であること'
      When call sx_arr_has myarr -6
      The status should be failure
    End

    It '+接頭辞を許すこと'
      When call sx_arr_has myarr +1
      The status should be success
    End

    It '-0 は 0 とみなすこと'
      When call sx_arr_has myarr -0
      The status should be success
    End
  End

  Context '範囲指定 (arr_len=5)'
    It '前方範囲に一致すること'
      When call sx_arr_has myarr 1:3
      The status should be success
    End

    It '逆方向範囲は負stepで一致すること'
      When call sx_arr_has myarr 3:0:-1
      The status should be success
    End

    It 'step付き範囲に一致すること'
      When call sx_arr_has myarr 0:5:2
      The status should be success
    End

    It '上側超過の始点は負stepで len-1 から一致すること'
      When call sx_arr_has myarr 5:0:-1
      The status should be success
    End

    It '下側超過の端点は 0 に丸められて一致すること'
      When call sx_arr_has myarr -10:1 -4:-2
      The status should be success
    End

    It '始点と終点が等しい範囲は空であること'
      When call sx_arr_has myarr 1:1
      The status should be failure
    End

    It '逆方向の範囲は既定step=1では空であること'
      When call sx_arr_has myarr 4:3
      The status should be failure
    End

    It '両端が範囲外の範囲は空であること'
      When call sx_arr_has myarr 7:8
      The status should be failure
    End

    It '方向とstepの符号が逆の範囲は空であること'
      When call sx_arr_has myarr 4:3:1 1:2:-1
      The status should be failure
    End

    It '負始点の刻みは位相を保持すること (-6:5:2 は一致)'
      When call sx_arr_has myarr -6:5:2
      The status should be success
    End

    It '負終端超過の降順は先頭まで含むこと (4:-99:-1 は一致)'
      When call sx_arr_has myarr 4:-99:-1
      The status should be success
    End

    It '5:3:-2 は d に一致すること (t<0 は終端を含む)'
      When call sx_arr_has myarr 5:3:-2
      The status should be success
    End

    It 's==e の負stepは単要素に一致すること'
      When call sx_arr_has myarr 2:2:-1
      The status should be success
    End
  End

  Context '終端省略'
    It 's: は末尾までの一致とすること'
      When call sx_arr_has myarr 2:
      The status should be success
    End

    It 's::-1 は先頭までの一致とすること'
      When call sx_arr_has myarr 2::-1
      The status should be success
    End

    It '上側超過の始点は負stepで len-1 から一致すること (5::-2 は一致)'
      When call sx_arr_has myarr 5::-2
      The status should be success
    End

    It '空配列の省略終端は失敗すること'
      sx_arr_gen empty_arr
      When call sx_arr_has empty_arr 2::-1 0:-5:-1
      The status should be failure
    End
  End

  Context '始点省略'
    It ':e は先頭からの一致とすること'
      When call sx_arr_has myarr :3
      The status should be success
    End

    It '::t は全件の一致とすること'
      When call sx_arr_has myarr ::2
      The status should be success
    End

    It '::-t は全件の逆順一致とすること'
      When call sx_arr_has myarr ::-1
      The status should be success
    End

    It ': は全件一致とすること'
      When call sx_arr_has myarr :
      The status should be success
    End

    It '空配列の始点省略は失敗すること'
      sx_arr_gen empty_arr
      When call sx_arr_has empty_arr ::-1 :
      The status should be failure
    End
  End

  Context 'getとの等価性 (has真 ⟺ get非空)'
    It '代表spec群で一致すること'
      mismatch=0
      for spec in 0 4 5 9 -1 -5 -6 -0 +1 0:3 1:1 4:3 7:8 4:3:1 1:2:-1 \
          3:0:-1 0:5:2 5:0:-1 5:3:-2 2: 2::-1 4::-2 5::-2 1::2 \
          -6:5:2 4:-99:-1 100:1:-2 1:10 -10:1 400:1:-1 -4:-2 1:-1 -1:1:-1 \
          6:10 2:2 0:5 400:500 0:5:100000000000000000000000 \
          4:0:-2147483648 -100000000000000000000000:5:1 \
          99999999999999999999999:1:-1 99999999999999999999999:-99:-1 \
          4:100000000000000000000000:1 99999999999999999999999:4:-1 :5 ::2 ::-1 : 2:2:-1 4:0:-1 4:0:-2 \
          0:0:-1 5:2:-1 :3 :0:-1 2:0:-2; do
        if sx_arr_has myarr "${spec}"; then hsts=0; else hsts=1; fi
        sx_var_unset x
        sx_arr_get x myarr "${spec}"
        if [ "${hsts}" -eq 0 ]; then
          [ "${x_len}" -gt 0 ] || mismatch=$((mismatch + 1))
        else
          [ "${x_len}" -eq 0 ] || mismatch=$((mismatch + 1))
        fi
      done
      sx_arr_gen empty_arr
      for spec in 0 -1 0:5 0:1 5:0:-1 3:0 0:-5:-1 2::-1 ::-1 :; do
        if sx_arr_has empty_arr "${spec}"; then hsts=0; else hsts=1; fi
        sx_var_unset x
        sx_arr_get x empty_arr "${spec}"
        if [ "${hsts}" -eq 0 ]; then
          [ "${x_len}" -gt 0 ] || mismatch=$((mismatch + 1))
        else
          [ "${x_len}" -eq 0 ] || mismatch=$((mismatch + 1))
        fi
      done
      The variable mismatch should equal 0
    End
  End

  Context '複数spec (すべて一致すれば成功)'
    It '一部が空なら失敗すること'
      When call sx_arr_has myarr 1 9
      The status should be failure
    End

    It '後方が空でも失敗すること'
      When call sx_arr_has myarr 9 1:2
      The status should be failure
    End

    It 'すべて空なら失敗すること'
      When call sx_arr_has myarr 9 10
      The status should be failure
    End

    It 'すべて空範囲なら失敗すること'
      When call sx_arr_has myarr 4:3 7:8
      The status should be failure
    End
  End

  Context '空配列・穴・空真'
    It '空の配列に対して単体 0 は失敗を返すこと'
      sx_arr_gen empty_arr
      When call sx_arr_has empty_arr 0
      The status should be failure
    End

    It '空の配列に対して -0 は失敗を返すこと (ガード経路)'
      sx_arr_gen empty_arr
      When call sx_arr_has empty_arr -0
      The status should be failure
    End

    It '空の配列に対して範囲は失敗を返すこと'
      sx_arr_gen empty_arr
      When call sx_arr_has empty_arr 0:5 5:0:-1
      The status should be failure
    End

    It '疎配列の穴は存在扱いとすること'
      unset myarr_1
      When call sx_arr_has myarr 1
      The status should be success
    End

    It 'specなしは空真で成功すること'
      When call sx_arr_has myarr
      The status should be success
    End
  End

  Context '異常系・エラーハンドリング'
    It '配列ではない変数に対して EX_DATAERR を返すこと'
      not_arr="not an array"
      When call sx_arr_has not_arr 0
      The status should equal 65
    End

    It '引数なしは EX_USAGE を返すこと'
      When call sx_arr_has
      The status should equal 64
    End

    It '無効な配列名に対して EX_USAGE を返すこと'
      When call sx_arr_has "9arr" 0
      The status should equal 64
    End

    It '数値ではない spec に対して EX_USAGE を返すこと'
      When call sx_arr_has myarr "len"
      The status should equal 64
    End

    It '前ゼロ付きに対して EX_USAGE を返すこと'
      When call sx_arr_has myarr 01
      The status should equal 64
    End

    It '=idx 形式に対して EX_USAGE を返すこと'
      When call sx_arr_has myarr =0
      The status should equal 64
    End

    It 'dest=idx 形式に対して EX_USAGE を返すこと'
      When call sx_arr_has myarr res=1
      The status should equal 64
    End

    It 'stepが0の範囲に対して EX_USAGE を返すこと'
      When call sx_arr_has myarr 0:5:0
      The status should equal 64
    End

    It '- 区切りに対して EX_USAGE を返すこと'
      When call sx_arr_has myarr 1-2
      The status should equal 64
    End

    It '空と形式不正の混在は EX_USAGE を優先すること'
      When call sx_arr_has myarr 9 len
      The status should equal 64
    End

    It '設定エラー (EX_CONFIG: 78) を検知すること'
      check_config() {
        SX_CFG_NUM_RANGE=99
        sx_arr_has myarr 0
      }

      When call check_config
      The status should equal 78
    End
  End

  Context '高速化モード (SX_CFG_SKIP_CHK=1)'
    It 'スキップモードでも範囲一致できること'
      SX_CFG_SKIP_CHK=1
      When call sx_arr_has myarr 1:3
      The status should be success
    End

    It 'スキップモードでも空なら失敗を返すこと'
      SX_CFG_SKIP_CHK=1
      When call sx_arr_has myarr 4:3
      The status should be failure
    End
  End
End
