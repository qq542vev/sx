Describe 'sx_str_split'
  Include ./sx.sh
  It '文字列を分割して配列に格納すること'
    When call sx_str_split myarr "a:b:c:d" ":"
    The status should be success
    The variable myarr_len should equal 4
    The variable myarr_0 should equal "a"
    The variable myarr_3 should equal "d"
  End

  It '回数制限付きで前方から分割すること'
    When call sx_str_split myarr "a:b:c:d" ":" 2 f
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c:d"
  End

  It '回数制限付きで後方から分割すること'
    When call sx_str_split myarr "a:b:c:d" ":" 2 b
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a:b"
    The variable myarr_1 should equal "c"
    The variable myarr_2 should equal "d"
  End

  It '特殊文字を処理できること'
    When call sx_str_split myarr "a'b:c\"d" ":" 1 f
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "a'b"
    The variable myarr_1 should equal "c\"d"
  End

  It '空の入力文字列を処理できること'
    When call sx_str_split myarr "" ":" 5 f
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal ""
  End
End
