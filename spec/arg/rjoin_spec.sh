#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_rjoin'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_arg_rjoin.sh

  It '引数個数に安全範囲の上限を適用しないこと'
    __sx_num_is_nat0_safe() {
      case "${1-}" in 5) return 1;; esac
      return 0
    }
    When call sx_arg_rjoin result : 'a b' '' "c'd"
    The status should be success
    The variable result should equal "c'd::a b"
  End

  It '引数を区切り文字で右から結合すること'
    When call sx_arg_rjoin result ":" "a" "b" "c"
    The status should be success
    The variable result should equal "c:b:a"
  End

  It '空の区切り文字を処理できること'
    When call sx_arg_rjoin result "" "a" "b" "c"
    The status should be success
    The variable result should equal "cba"
  End

  It '引数が1つの場合は区切り文字なしでそのまま格納すること'
    When call sx_arg_rjoin result ":" "a"
    The status should be success
    The variable result should equal "a"
  End

  It '引数がない場合（結果変数と区切り文字のみ）は空文字列を格納すること'
    When call sx_arg_rjoin result ":"
    The status should be success
    The variable result should equal ""
  End

  It '特殊文字を含む引数を右から結合できること'
    When call sx_arg_rjoin result "," "a b" "c'd" 'e"f'
    The status should be success
    The variable result should equal "e\"f,c'd,a b"
  End

  It 'IFSの先頭文字と区切り文字が一致する場合に結合できること'
    with_ifs_colon() { IFS='::' "${@}"; }
    When call with_ifs_colon sx_arg_rjoin result ":" "a" "" "b"
    The status should be success
    The variable result should equal "b::a"
  End

  It 'IFSの先頭文字がパターン記号でも正しく結合できること'
    with_ifs_pattern() { IFS='*?' "${@}"; }
    When call with_ifs_pattern sx_arg_rjoin result "*" "a" "b"
    The status should be success
    The variable result should equal "b*a"
  End

  It 'IFSが空で区切り文字も空の場合に結合できること'
    with_ifs_empty() { IFS= "${@}"; }
    When call with_ifs_empty sx_arg_rjoin result "" "a" "" "b"
    The status should be success
    The variable result should equal "ba"
  End

  It 'IFSが1文字で区切り文字が空の場合は区切りなしで結合すること'
    with_ifs_single_colon() { IFS=: "${@}"; }
    When call with_ifs_single_colon sx_arg_rjoin result "" "a" "b"
    The status should be success
    The variable result should equal "ba"
  End

  It 'IFSが同じ文字の繰り返しで区切り文字が空の場合は区切りなしで結合すること'
    with_ifs_colon() { IFS='::' "${@}"; }
    When call with_ifs_colon sx_arg_rjoin result "" "a" "b"
    The status should be success
    The variable result should equal "ba"
  End

  It 'IFSが未設定で空白区切りの場合に結合できること'
    sxtest_run result -- 'unset IFS; sx_arg_rjoin result " " "a" "" "b"'
    The variable result should equal "b  a"
  End

  It 'IFSの先頭文字と異なる区切り文字では指定どおり結合すること'
    with_ifs_colon() { IFS='::' "${@}"; }
    When call with_ifs_colon sx_arg_rjoin result "/" "a" "b"
    The status should be success
    The variable result should equal "b/a"
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_join="fixed"
    When call sx_arg_rjoin ro_res_join ":" "a" "b"
    The status should equal 77
  End

  It '結果変数が無効な名前の場合に EX_USAGE を返すること'
    When call sx_arg_rjoin "1invalid" ":" "a"
    The status should equal 64
  End
End
