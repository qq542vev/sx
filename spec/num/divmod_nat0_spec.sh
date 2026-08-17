#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_divmod_nat0'
  Include ./sx.sh

  # ホストの算術展開が 64bit 未満か判定する（32bit ホストでは 2^31 超の演算が致命的 overflow になるため）
  arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }

  It '小さな数の除算ができること（あまりなし）'
    When call sx_num_divmod_nat0 "q:r:" 100 4
    The status should be success
    The variable q should equal "25"
    The variable r should equal "0"
  End

  It '小さな数の除算ができること（あまりあり）'
    When call sx_num_divmod_nat0 "q:r:" 100 3
    The status should be success
    The variable q should equal "33"
    The variable r should equal "1"
  End

  It '被除数が除数より小さい場合の除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 5 10
    The status should be success
    The variable q should equal "0"
    The variable r should equal "5"
  End

  It '被除数と除数が等しい場合の除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 42 42
    The status should be success
    The variable q should equal "1"
    The variable r should equal "0"
  End

  It '被除数が0の場合の除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 0 42
    The status should be success
    The variable q should equal "0"
    The variable r should equal "0"
  End

  It '単精度除数で多倍長整数の除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 1000000000000000000 3
    The status should be success
    The variable q should equal "333333333333333333"
    The variable r should equal "1"
  End

  It '多精度除数で大きな数の除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 98765431209876543120 12345678901234567890
    The status should be success
    The variable q should equal "8"
    The variable r should equal "0"
  End

  It '多精度除数で余りが出る大きな数の除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 12345678901234567890 12345678900000000000
    The status should be success
    The variable q should equal "1"
    The variable r should equal "1234567890"
  End

  It '一般パス(d=0)の除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 192837465564738291019283746 987654321012
    The status should be success
    The variable q should equal "195247933879484"
    The variable r should equal "649962365938"
  End

  It '一般パス(d=1)の除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 192837465564738291019283746 98765432101
    The status should be success
    The variable q should equal "1952479338798800"
    The variable r should equal "34719004946"
  End

  It '一般パス(d=2)の除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 99999999999999999999 4999999999
    The status should be success
    The variable q should equal "20000000004"
    The variable r should equal "3"
  End

  It '一般パスで商の見積りが過大となり加算復帰(D5)が行われること'
    When call sx_num_divmod_nat0 "q:r:" 1440210458806853161311156 2586403716
    The status should be success
    The variable q should equal "556838999997343"
    The variable r should equal "1235984568"
  End

  It '高速パス5で除数が短い大きな数の除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 102030405060708090100 90909
    The status should be success
    The variable q should equal "1122335578003366"
    The variable r should equal "90406"
  End

  It '高速パス5で全ゼロの語を商にゼロ埋めする除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 1000000000000000 10
    The status should be success
    The variable q should equal "100000000000000"
    The variable r should equal "0"
  End

  It '末尾ゼロ分解を経由する除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 12345678900000000000123456789 123400000000
    The status should be success
    The variable q should equal "100046020259319286"
    The variable r should equal "107723456789"
  End

  It '末尾ゼロ分解で被除数がネイティブ幅に収まる高速パス4で除算ができること'
    When call sx_num_divmod_nat0 "q:r:" 123456789000111222333444 3000000000000000
    The status should be success
    The variable q should equal "41152263"
    The variable r should equal "111222333444"
  End

  Context '64ビット設定'
    Before 'SX_CFG_NUM_RANGE=64'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64

    It '一般パス(d>0)の除算ができること'
      When call sx_num_divmod_nat0 "q:r:" 123456789012345678901234567890 1234567890123456789
      The status should be success
      The variable q should equal "100000000000"
      The variable r should equal "1234567890"
    End

    It '高速パス5で除数が短い大きな数の除算ができること'
      When call sx_num_divmod_nat0 "q:r:" 123456789012345678901234567890 999999999
      The status should be success
      The variable q should equal "123456789135802468037"
      The variable r should equal "37035927"
    End
  End

  It 'ゼロ除算でエラー(64)になること'
    When call sx_num_divmod_nat0 "q:r:" 100 0
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合にエラー(77)になること'
    readonly ro_res_int_divmod_abs="const"
    When call sx_num_divmod_nat0 "ro_res_int_divmod_abs:r:" 100 4
    The status should equal 77
  End

  It '設定エラー(78)を検知すること'
    check_config() {
      SX_CFG_NUM_RANGE=99
      sx_num_divmod_nat0 "q:r:" 100 4
    }
    When call check_config
    The status should equal 78
  End

  It '除数を省略した場合は除数1として扱われること'
    When call sx_num_divmod_nat0 "q:r:" 100
    The status should be success
    The variable q should equal "100"
    The variable r should equal "0"
  End

  It '負数を含む場合はエラー(64)になること'
    When call sx_num_divmod_nat0 "q:r:" 100 -5
    The status should equal 64
  End

  It '非数値を含む場合はエラー(64)になること'
    When call sx_num_divmod_nat0 "q:r:" 100 abc
    The status should equal 64
  End
End
