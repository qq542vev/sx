#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_pop'
  Include ./sx.sh

  Describe '基本 pop'
    It '末尾の1要素をスカラーへ取り出し、元配列から削除すること'
      sx_arr_gen myarr a b c

      When call sx_arr_pop x: myarr
      The status should be success
      The variable x should equal "c"
      The variable myarr_len should equal 2
      The variable myarr_2 should be undefined
    End

    It '複数スロットへ末尾順に取り出すこと'
      sx_arr_gen myarr a b c

      When call sx_arr_pop x:y: myarr
      The status should be success
      The variable x should equal "c"
      The variable y should equal "b"
      The variable myarr_len should equal 1
      The variable myarr_2 should be undefined
      The variable myarr_1 should be undefined
    End

    It '全要素を取り出すと元配列が空になること'
      sx_arr_gen myarr a b c

      When call sx_arr_pop x:y:z: myarr
      The status should be success
      The variable x should equal "c"
      The variable y should equal "b"
      The variable z should equal "a"
      The variable myarr_len should equal 0
      The variable myarr_0 should be undefined
    End

    It '元配列が sx 配列のまま残ること'
      sx_arr_gen myarr a b c

      When call sx_arr_pop x: myarr
      The status should be success
      The variable myarr should start with "array-sx-sig-"
    End
  End

  Describe '配列と破棄'
    It '数値プレフィックスで配列へ複数割り当てること'
      sx_arr_gen myarr a b c

      When call sx_arr_pop 2v: myarr
      The status should be success
      The variable v_len should equal 2
      The variable v_0 should equal "c"
      The variable v_1 should equal "b"
      The variable v_2 should be undefined
      The variable myarr_len should equal 1
      The variable myarr_0 should equal "a"
    End

    It '数値セグメントで要素を破棄できること'
      sx_arr_gen myarr a b c d

      When call sx_arr_pop 2v:1:w: myarr
      The status should be success
      The variable v_len should equal 2
      The variable v_0 should equal "d"
      The variable v_1 should equal "c"
      The variable w should equal "a"
      The variable myarr_len should equal 0
    End

    It '破棄のみの bind でも正しく要素が削除されること'
      sx_arr_gen myarr a b c

      When call sx_arr_pop 2: myarr
      The status should be success
      The variable myarr_len should equal 1
      The variable myarr_0 should equal "a"
      The variable myarr_2 should be undefined
    End
  End

  Describe '要素不足と失敗'
    It 'スロット数が要素数を超える場合に 1 を返し、何も変更しないこと'
      sx_arr_gen myarr a b c

      When call sx_arr_pop x:y:z:w: myarr
      The status should equal 1
      The variable x should be undefined
      The variable y should be undefined
      The variable z should be undefined
      The variable w should be undefined
      The variable myarr_len should equal 3
      The variable myarr_0 should equal "a"
      The variable myarr_2 should equal "c"
    End

    It '末尾「:」の無い bind（x）は要素不足となり 1 を返すこと'
      sx_arr_gen myarr a b c

      When call sx_arr_pop x myarr
      The status should equal 1
      The variable x should be undefined
      The variable myarr_len should equal 3
    End

    It '末尾「:」の無い bind（x:y）も 1 を返し無変更であること'
      sx_arr_gen myarr a b c

      When call sx_arr_pop x:y myarr
      The status should equal 1
      The variable x should be undefined
      The variable y should be undefined
      The variable myarr_len should equal 3
    End

    It '空の配列から pop すると 1 を返すこと'
      sx_arr_gen myarr

      When call sx_arr_pop x: myarr
      The status should equal 1
      The variable x should be undefined
      The variable myarr_len should equal 0
    End
  End

  Describe '64ビット設定'
    It '数値プレフィックスの割り当てが正しく動作すること'
      sx_arr_gen myarr a b c d e
      SX_CFG_NUM_RANGE=64

      When call sx_arr_pop 3v: myarr
      The status should be success
      The variable v_len should equal 3
      The variable v_0 should equal "e"
      The variable v_2 should equal "c"
      The variable myarr_len should equal 2
    End
  End

  Describe 'バリデーション'
    It 'bind が不正な場合に 64 を返すこと'
      sx_arr_gen myarr a b

      When call sx_arr_pop "0x:" myarr
      The status should equal 64
    End

    It 'bind が不正な場合に 64 を返すこと（先頭0）'
      sx_arr_gen myarr a b

      When call sx_arr_pop "a  b:" myarr
      The status should equal 64
    End

    It '@ を含む bind の場合に 64 を返すこと'
      sx_arr_gen myarr a b

      When call sx_arr_pop "x:@arr:" myarr
      The status should equal 64
    End

    It '配列名が未指定の場合に 64 を返すこと'
      sx_arr_gen myarr a b

      When call sx_arr_pop x:
      The status should equal 64
    End

    It '対象が sx 配列でない場合に 65 を返すこと'
      not_an_arr="val"

      When call sx_arr_pop x: not_an_arr
      The status should equal 65
    End

    It '分配先が読み取り専用の場合に 77 を返すこと'
      sx_arr_gen myarr a b c
      readonly x

      When call sx_arr_pop x: myarr
      The status should equal 77
    End

    It '元配列の _len が読み取り専用の場合に 77 を返すこと'
      sx_arr_gen myarr a b c
      readonly myarr_len

      When call sx_arr_pop x: myarr
      The status should equal 77
    End

    It '設定エラー (EX_CONFIG: 78) を検知すること'
      sx_arr_gen myarr a b
      check_config() {
        SX_CFG_NUM_RANGE=99
        sx_arr_pop x: myarr
      }

      When call check_config
      The status should equal 78
    End
  End

  Describe 'SX_CFG_SKIP_CHK モード'
    It 'checkskip 有効時も成功する'
      sx_arr_gen myarr a b c
      SX_CFG_SKIP_CHK=1

      When call sx_arr_pop x: myarr
      The status should be success
      The variable x should equal "c"
      The variable myarr_len should equal 2
    End

    It 'checkskip 有効時も要素不足で 1 を返すこと'
      sx_arr_gen myarr a b c
      SX_CFG_SKIP_CHK=1

      When call sx_arr_pop x:y:z:w: myarr
      The status should equal 1
      The variable myarr_len should equal 3
    End
  End
End