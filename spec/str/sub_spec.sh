#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_sub'
  Include ./sx.sh
  It 'パターンを文字列で置換すること'
    When call sx_str_sub result "hello world" "world" "earth"
    The status should be success
    The variable result should equal "hello earth"
  End

  It 'パターンが見つからない場合は何もしないこと'
    When call sx_str_sub result "hello world" "foo" "bar"
    The status should be success
    The variable result should equal "hello world"
  End

  It '空文字列で置換（削除）できること'
    When call sx_str_sub result "hello world" "hello " ""
    The status should be success
    The variable result should equal "world"
  End

  It '特殊文字を含む置換ができること'
    When call sx_str_sub result "a'b\"c\\d" "'" "_"
    The status should be success
    The variable result should equal "a_b\"c\\d"
  End

  Context '方向と制限を指定した場合'
    It 'デフォルトで前方からすべて置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_"
      The variable res should equal "a_b_c_d"
    End

    It '制限1で前方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" 1
      The variable res should equal "a_b.c.d"
    End

    It '制限2で前方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" 2
      The variable res should equal "a_b_c.d"
    End

    It '制限1で後方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" -1
      # 期待値: a.b.c_d (後方から1つ)
      The variable res should equal "a.b.c_d"
    End

    It '制限2で後方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" -2
      # 期待値: a.b_c_d (後方から2つ)
      The variable res should equal "a.b_c_d"
    End
  End

  Context '空文字列パターンを置換する場合'
    It 'すべて置換（文字間と両端に挿入）すること'
      When call sx_str_sub res "abc" "" "X"
      The variable res should equal "XaXbXcX"
    End

    It '前方制限1で先頭に挿入すること'
      When call sx_str_sub res "abc" "" "X" 1
      The variable res should equal "Xabc"
    End

    It '前方制限2で先頭と1文字目の後に挿入すること'
      When call sx_str_sub res "abc" "" "X" 2
      The variable res should equal "XaXbc"
    End

    It '後方制限1で末尾に挿入すること'
      When call sx_str_sub res "abc" "" "X" -1
      The variable res should equal "abcX"
    End

    It '後方制限2で末尾と最後の文字の前に挿入すること'
      When call sx_str_sub res "abc" "" "X" -2
      The variable res should equal "abXcX"
    End

    It '空文字列に対して置換すると置換文字列自身になること'
      When call sx_str_sub res "" "" "X"
      The variable res should equal "X"
    End
  End

  It '無効な引数（回数不正）に対して EX_USAGE を返すこと'
    When call sx_str_sub result "a.b" "." "_" "abc"
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_sub="fixed"
    When call sx_str_sub ro_res_sub "a" "a" "b"
    The status should equal 77
  End

  It 'glob モードで * のみのパターンは空パターン相当になること'
    sx_str_sub res "abc" "*" "X" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_GLOB}"
    Assert sx_str_eq "${res}" "XaXbXcX"
  End

  It '非 glob モードでは * はリテラルとして扱われること'
    sx_str_sub res "a*b" "*" "X"
    Assert sx_str_eq "${res}" "aXb"
  End

  It 'glob モードで * のみのパターン、制限付き前方置換ができること'
    sx_str_sub res "abc" "*" "X" 2 "${SX_STR_SUB_GLOB}"
    Assert sx_str_eq "${res}" "XaXbc"
  End

  It 'glob モードで * のみのパターン、制限付き後方置換ができること'
    sx_str_sub res "abc" "*" "X" -2 "${SX_STR_SUB_GLOB}"
    Assert sx_str_eq "${res}" "abXcX"
  End

  It 'glob モードで * のみのパターン、空文字列に対する置換'
    sx_str_sub res "" "*" "X" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_GLOB}"
    Assert sx_str_eq "${res}" "X"
  End
End
