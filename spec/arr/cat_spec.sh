#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_cat'
  Include ./spec/support/run.sh
  Include ./spec/support/library.sh sx_arr_cat

  Describe '基本連結'
    It '複数の配列を1つの末尾配列へ順に連結すること'
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen a1 a b c
        sx_arr_gen a2 d e
      '
      sxtest_run a1 a2 SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"

      When call sx_arr_cat x a1 a2
      The status should be success
      The variable x_len should equal 5
      The variable x_0 should equal "a"
      The variable x_1 should equal "b"
      The variable x_2 should equal "c"
      The variable x_3 should equal "d"
      The variable x_4 should equal "e"
    End

    It '空文字列や特殊文字を含む要素も正しく連結すること'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1 "" "it's" 'say "hello"'

      When call sx_arr_cat x a1
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal ""
      The variable x_1 should equal "it's"
      The variable x_2 should equal 'say "hello"'
    End

    It '源配列が1つのみの場合にそのまま連結すること'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1 p q r

      When call sx_arr_cat x a1
      The status should be success
      The variable x_len should equal 3
      The variable x_0 should equal "p"
      The variable x_1 should equal "q"
      The variable x_2 should equal "r"
    End
  End

  Describe '分配'
    It '数値先行セグメントと末尾セグメントへ要素ずつ分配すること'
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen a1 a b c
        sx_arr_gen a2 d e
      '
      sxtest_run a1 a2 SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"

      When call sx_arr_cat 2a:x a1 a2
      The status should be success
      The variable a_len should equal 2
      The variable a_0 should equal "a"
      The variable a_1 should equal "b"
      The variable x_len should equal 3
      The variable x_0 should equal "c"
      The variable x_1 should equal "d"
      The variable x_2 should equal "e"
    End

    It '素セグメントはスカラーとして扱い配列化しないこと'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1 p q r s t

      When call sx_arr_cat a:2b:x a1
      The status should be success
      The variable a should equal "p"
      The variable b_len should equal 2
      The variable b_0 should equal "q"
      The variable b_1 should equal "r"
      The variable x_len should equal 2
      The variable x_0 should equal "s"
      The variable x_1 should equal "t"
    End
  End

  Describe 'スカラーを挟む部分充填（回帰対策）'
    It '数値先行セグメントが未満充填でも正しい長さになること'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1 p

      When call sx_arr_cat 2a:b:x a1
      The status should be success
      The variable a_len should equal 1
      The variable a_0 should equal "p"
      The variable a_1 should be undefined
      The variable x_len should equal 0
    End

    It '源が空でも中間スカラーがあれば空配列を生成すること'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1

      When call sx_arr_cat 2a:b:x a1
      The status should be success
      The variable a_len should equal 0
      The variable a_0 should be undefined
      The variable x_len should equal 0
    End

    It '複数配列を跨ぐ分配でも後続セグメントの長さが正しいこと'
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen a1 p q
        sx_arr_gen a2 r
      '
      sxtest_run a1 a2 SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"

      When call sx_arr_cat 2a:2b:c:x a1 a2
      The status should be success
      The variable a_len should equal 2
      The variable b_len should equal 1
      The variable b_0 should equal "r"
      The variable x_len should equal 0
    End

    It '数値スキップセグメントを挟んでも正しい長さになること'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1 p q r

      When call sx_arr_cat 2a:2:2b:x a1
      The status should be success
      The variable a_len should equal 2
      The variable b_len should equal 0
      The variable x_len should equal 0
    End
  End

  Describe '空源と切り詰め'
    It '引数が0個の場合に 64 を返すこと'
      When call sx_arr_cat
      The status should equal 64
    End

    It '源配列が無い場合に空配列を生成すること'
      When call sx_arr_cat x
      The status should be success
      The variable x_len should equal 0
    End

    It '源配列が空の場合に空配列を生成すること'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1

      When call sx_arr_cat x a1
      The status should be success
      The variable x_len should equal 0
    End

    It '要素が不足する場合に切り詰めて成功すること'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1 p q r

      When call sx_arr_cat 2a:x a1
      The status should be success
      The variable a_len should equal 2
      The variable a_0 should equal "p"
      The variable a_1 should equal "q"
      The variable x_len should equal 1
      The variable x_0 should equal "r"
    End
  End

  Describe '64ビット設定'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    It '複数の配列を1つの末尾配列へ順に連結すること'
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen a1 a b c
        sx_arr_gen a2 d e
        sx_cfg_set NUM_RANGE=64
      '
      sxtest_run a1 a2 SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"

      When call sx_arr_cat x a1 a2
      The status should be success
      The variable x_len should equal 5
      The variable x_0 should equal "a"
      The variable x_4 should equal "e"
    End

    It '数値先行セグメントと末尾セグメントへ分配すること'
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen a1 a b c
        sx_arr_gen a2 d e
        sx_cfg_set NUM_RANGE=64
      '
      sxtest_run a1 a2 SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"

      When call sx_arr_cat 2a:x a1 a2
      The status should be success
      The variable a_len should equal 2
      The variable a_0 should equal "a"
      The variable x_len should equal 3
      The variable x_0 should equal "c"
    End

    It '源配列が空の場合は空配列を生成すること'
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen a1
        sx_cfg_set NUM_RANGE=64
      '
      sxtest_run a1 SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"

      When call sx_arr_cat x a1
      The status should be success
      The variable x_len should equal 0
    End
  End

  Describe 'バリデーション'
    It 'バインド形式が不正な場合に 64 を返すこと'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1 a b

      When call sx_arr_cat "2b" a1
      The status should equal 64
    End

    It '先頭0のバインド形式が不正な場合に 64 を返すこと'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1 a b

      When call sx_arr_cat "0a" a1
      The status should equal 64
    End

    It '@ を含むバインド形式の場合に 64 を返すこと'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1 a b

      When call sx_arr_cat "x:@arr" a1
      The status should equal 64
    End

    It '対象が sx 配列でない場合に 65 を返すこと'
      notarr=1

      When call sx_arr_cat x notarr
      The status should equal 65
    End

    It '設定エラー (EX_CONFIG: 78) を検知すること'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1 a b
      check_config() {
        SX_CFG_NUM_RANGE=99
        sx_arr_cat x a1
      }

      When call check_config
      The status should equal 78
    End
  End

  Describe 'トランザクション'
    It '分配先が読み取り専用の場合に 77 を返し、他の分配先にも書き込まないこと'
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen a1 a b c
        sx_arr_gen a2 d e
      '
      sxtest_run a1 a2 SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      readonly x
      unset a

      When call sx_arr_cat 2a:x a1 a2
      The status should equal 77
      The variable a_len should be undefined
      The variable a_0 should be undefined
    End

    It '分配先要素が読み取り専用の場合に 77 を返し、他の分配先にも書き込まないこと'
      sxtest_run a1 SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" a1 p q
      readonly a_1

      When call sx_arr_cat 2a:x a1
      The status should equal 77
      The variable a_len should be undefined
      The variable a_0 should be undefined
      The variable x_len should be undefined
    End

    It '読み取り専用でない通常の分配では全要素が正しく書き込まれること'
      setup_command='
        SX_SYS_REV=$1
        sx_arr_gen a1 a b c
        sx_arr_gen a2 d e
      '
      sxtest_run a1 a2 SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      unset a x

      When call sx_arr_cat 2a:x a1 a2
      The status should be success
      The variable a_len should equal 2
      The variable a_0 should equal "a"
      The variable a_1 should equal "b"
      The variable x_len should equal 3
      The variable x_0 should equal "c"
      The variable x_1 should equal "d"
      The variable x_2 should equal "e"
    End
  End
End
