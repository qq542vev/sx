#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_at'
  Include ./sx.sh
  BeforeEach 'sx_arr_gen myarr "a" "b" "c"'

  Context '存在確認 (単一数値指定)'
    It '存在するインデックスに対して成功を返すこと'
      When call sx_arr_at myarr 0
      The status should be success
    End

    It '複数の存在するインデックスに対して成功を返すこと'
      When call sx_arr_at myarr 0 1 2
      The status should be success
    End

    It '範囲外のインデックスに対して失敗を返すこと'
      When call sx_arr_at myarr 3
      The status should be failure
    End

    It '一部が範囲外の場合に失敗を返すこと'
      When call sx_arr_at myarr 1 4
      The status should be failure
    End

    It '空の配列に対してインデックス 0 は失敗を返すこと'
      sx_arr_gen empty_arr
      When call sx_arr_at empty_arr 0
      The status should be failure
    End
  End

  Context '要素取得 (dest=idx指定)'
    It '要素を正常に取得できること'
      When call sx_arr_at myarr res=1
      The variable res should equal "b"
      The status should be success
    End

    It '複数の要素を一度に取得できること'
      When call sx_arr_at myarr r0=0 r2=2
      The variable r0 should equal "a"
      The variable r2 should equal "c"
      The status should be success
    End

    It '取得と存在確認を混在させても動作すること'
      When call sx_arr_at myarr r1=1 2
      The variable r1 should equal "b"
      The status should be success
    End

    It '混在時に一つでも範囲外があれば失敗すること'
      When call sx_arr_at myarr r1=1 5
      The status should be failure
    End

    It '結果変数が読み取り専用の場合は NOPERM を返すこと'
      readonly ro_var="read only"
      When call sx_arr_at myarr ro_var=0
      The status should equal 77
    End
  End

  Context '異常系・エラーハンドリング'
    It '配列ではない変数に対して EX_DATAERR を返すこと'
      not_arr="not an array"
      When call sx_arr_at not_arr 0
      The status should equal 65
    End

    It '数値ではないインデックスに対して EX_USAGE を返すこと'
      When call sx_arr_at myarr "len"
      The status should equal 64
    End

    It '自己参照（ソース配列内への書き込み）を禁止すること'
      When call sx_arr_at myarr myarr_0=1
      The status should equal 64
    End
  End

  Context '高速化モード (SX_CFG_SKIP_CHK=1)'
    It 'スキップモードでも正常に取得できること'
      SX_CFG_SKIP_CHK=1
      When call sx_arr_at myarr res=1
      The variable res should equal "b"
      The status should be success
    End

    It 'スキップモードでも範囲外なら失敗を返すこと'
      SX_CFG_SKIP_CHK=1
      When call sx_arr_at myarr 3
      The status should be failure
    End
  End
End
