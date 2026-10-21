#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_join'
  Include ./spec/support/library.sh sx_arg_join

  It '引数個数に安全範囲の上限を適用しないこと'
    # 巨大な引数リストを作らず、呼び出し時の個数5を範囲外とする。
    __sx_num_is_nat0_safe() {
      case "${1-}" in 5) return 1;; esac
      return 0
    }
    When call sx_arg_join result : 'a b' '' "c'd"
    The status should be success
    The variable result should equal "a b::c'd"
  End

  It '引数を区切り文字で結合すること'
    When call sx_arg_join result ":" "a" "b" "c"
    The status should be success
    The variable result should equal "a:b:c"
  End

  It '空の区切り文字を処理できること'
    When call sx_arg_join result "" "a" "b" "c"
    The status should be success
    The variable result should equal "abc"
  End

  It '引数が1つの場合は区切り文字なしでそのまま格納すること'
    When call sx_arg_join result ":" "a"
    The status should be success
    The variable result should equal "a"
  End

  It '引数がない場合（結果変数と区切り文字のみ）は空文字列を格納すること'
    When call sx_arg_join result ":"
    The status should be success
    The variable result should equal ""
  End

  It '特殊文字を含む引数を結合できること'
    When call sx_arg_join result "," "a b" "c'd" 'e"f'
    The status should be success
    The variable result should equal "a b,c'd,e\"f"
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_join="fixed"
    When call sx_arg_join ro_res_join ":" "a" "b"
    The status should equal 77
  End

  It '結果変数が無効な名前の場合に EX_USAGE を返すこと'
    When call sx_arg_join "1invalid" ":" "a"
    The status should equal 64
  End
End
