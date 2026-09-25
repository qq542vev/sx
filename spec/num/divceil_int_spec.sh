#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_divceil_int'
  Include ./sx.sh

  # ホストの算術展開が 64bit 未満か判定する（32bit ホストでは 2^31 超の演算が致命的 overflow になるため）
  arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }

  It '小さな数の除算ができること（あまりなし）'
    When call sx_num_divceil_int q 100 4
    The status should be success
    The variable q should equal "25"
  End

  It '小さな数の除算ができること（あまりありは切り上げ）'
    When call sx_num_divceil_int q 100 3
    The status should be success
    The variable q should equal "34"
  End

  It '正の被除数を負の除数で除算できること（あまりなし）'
    When call sx_num_divceil_int q 100 -4
    The status should be success
    The variable q should equal "-25"
  End

  It '正の被除数を負の除数で除算できること（あまりありは0方向）'
    When call sx_num_divceil_int q 100 -3
    The status should be success
    The variable q should equal "-33"
  End

  It '負の被除数を正の除数で除算できること（あまりなし）'
    When call sx_num_divceil_int q -100 4
    The status should be success
    The variable q should equal "-25"
  End

  It '負の被除数を正の除数で除算できること（あまりありは0方向）'
    When call sx_num_divceil_int q -100 3
    The status should be success
    The variable q should equal "-33"
  End

  It '負の被除数を負の除数で除算できること（あまりなし）'
    When call sx_num_divceil_int q -100 -4
    The status should be success
    The variable q should equal "25"
  End

  It '負の被除数を負の除数で除算できること（あまりありは切り上げ）'
    When call sx_num_divceil_int q -100 -3
    The status should be success
    The variable q should equal "34"
  End

  It '符号の組み合わせで切り上げになること (7/3)'
    When call sx_num_divceil_int q 7 3
    The status should be success
    The variable q should equal "3"
  End

  It '符号の組み合わせで切り上げになること (-7/3)'
    When call sx_num_divceil_int q -7 3
    The status should be success
    The variable q should equal "-2"
  End

  It '符号の組み合わせで切り上げになること (7/-3)'
    When call sx_num_divceil_int q 7 -3
    The status should be success
    The variable q should equal "-2"
  End

  It '符号の組み合わせで切り上げになること (-7/-3)'
    When call sx_num_divceil_int q -7 -3
    The status should be success
    The variable q should equal "3"
  End

  It '符号の組み合わせで切り上げになること (7/-2)'
    When call sx_num_divceil_int q 7 -2
    The status should be success
    The variable q should equal "-3"
  End

  It '符号の組み合わせで切り上げになること (-7/2)'
    When call sx_num_divceil_int q -7 2
    The status should be success
    The variable q should equal "-3"
  End

  It '被除数が除数より小さい場合は1になること'
    When call sx_num_divceil_int q 5 10
    The status should be success
    The variable q should equal "1"
  End

  It '被除数が除数より小さい場合の負数は0になること (-5/10)'
    When call sx_num_divceil_int q -5 10
    The status should be success
    The variable q should equal "0"
  End

  It '被除数が除数より小さい場合の負数は0になること (5/-10)'
    When call sx_num_divceil_int q 5 -10
    The status should be success
    The variable q should equal "0"
  End

  It '被除数が除数より小さい場合の負数どうしは1になること'
    When call sx_num_divceil_int q -5 -10
    The status should be success
    The variable q should equal "1"
  End

  It '被除数と除数が等しい場合の除算ができること'
    When call sx_num_divceil_int q 42 42
    The status should be success
    The variable q should equal "1"
  End

  It '被除数と除数が等しい場合の負数の除算ができること'
    When call sx_num_divceil_int q -42 42
    The status should be success
    The variable q should equal "-1"
  End

  It '被除数と除数が等しい場合の負数どうしの除算ができること'
    When call sx_num_divceil_int q -42 -42
    The status should be success
    The variable q should equal "1"
  End

  It '被除数が0の場合の除算ができること'
    When call sx_num_divceil_int q 0 42
    The status should be success
    The variable q should equal "0"
  End

  It '被除数が0の場合の負の除数の除算ができること'
    When call sx_num_divceil_int q 0 -42
    The status should be success
    The variable q should equal "0"
  End

  It '明示的な符号付きの除算ができること'
    When call sx_num_divceil_int q +7 3
    The status should be success
    The variable q should equal "3"
  End

  It '単精度除数で多倍長整数の除算ができること'
    When call sx_num_divceil_int q 1000000000000000000 3
    The status should be success
    The variable q should equal "333333333333333334"
  End

  It '単精度除数で負の多倍長整数の除算ができること'
    When call sx_num_divceil_int q -1000000000000000000 3
    The status should be success
    The variable q should equal "-333333333333333333"
  End

  It '多精度除数で割り切れる大きな数の除算ができること'
    When call sx_num_divceil_int q 98765431209876543120 12345678901234567890
    The status should be success
    The variable q should equal "8"
  End

  It '多精度除数で割り切れる負の大きな数の除算ができること'
    When call sx_num_divceil_int q -98765431209876543120 12345678901234567890
    The status should be success
    The variable q should equal "-8"
  End

  It '多精度除数で余りが出る大きな数の除算ができること'
    When call sx_num_divceil_int q 12345678901234567890 12345678900000000000
    The status should be success
    The variable q should equal "2"
  End

  It '多精度除数で余りが出る負の大きな数の除算ができること'
    When call sx_num_divceil_int q -12345678901234567890 12345678900000000000
    The status should be success
    The variable q should equal "-1"
  End

  It '一般パス(d=0)の除算ができること'
    When call sx_num_divceil_int q 192837465564738291019283746 987654321012
    The status should be success
    The variable q should equal "195247933879485"
  End

  It '一般パス(d=0)の負数の除算ができること'
    When call sx_num_divceil_int q -192837465564738291019283746 987654321012
    The status should be success
    The variable q should equal "-195247933879484"
  End

  It '一般パス(d=1)の除算ができること'
    When call sx_num_divceil_int q 192837465564738291019283746 98765432101
    The status should be success
    The variable q should equal "1952479338798801"
  End

  It '一般パス(d=2)の除算ができること'
    When call sx_num_divceil_int q 99999999999999999999 4999999999
    The status should be success
    The variable q should equal "20000000005"
  End

  It '一般パス(d=2)の負数の除算ができること'
    When call sx_num_divceil_int q -99999999999999999999 4999999999
    The status should be success
    The variable q should equal "-20000000004"
  End

  It '一般パスで商の見積りが過大となり加算復帰(D5)が行われること'
    When call sx_num_divceil_int q 1440210458806853161311156 2586403716
    The status should be success
    The variable q should equal "556838999997344"
  End

  It '高速パス5で除数が短い大きな数の除算ができること'
    When call sx_num_divceil_int q 102030405060708090100 90909
    The status should be success
    The variable q should equal "1122335578003367"
  End

  It '高速パス5で全ゼロの語を商にゼロ埋めする除算ができること'
    When call sx_num_divceil_int q 1000000000000000 10
    The status should be success
    The variable q should equal "100000000000000"
  End

  It '末尾ゼロ分解を経由する除算ができること'
    When call sx_num_divceil_int q 12345678900000000000123456789 123400000000
    The status should be success
    The variable q should equal "100046020259319287"
  End

  It '末尾ゼロ分解で被除数がネイティブ幅に収まる高速パス4で除算ができること'
    When call sx_num_divceil_int q 123456789000111222333444 3000000000000000
    The status should be success
    The variable q should equal "41152264"
  End

  Context '64ビット設定'
    Before 'SX_CFG_NUM_RANGE=64'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64

    It '一般パス(d>0)の除算ができること'
      When call sx_num_divceil_int q 123456789012345678901234567890 1234567890123456789
      The status should be success
      The variable q should equal "100000000001"
    End

    It '一般パス(d>0)の負数の除算ができること'
      When call sx_num_divceil_int q -123456789012345678901234567890 1234567890123456789
      The status should be success
      The variable q should equal "-100000000000"
    End

    It '高速パス5で除数が短い大きな数の除算ができること'
      When call sx_num_divceil_int q 123456789012345678901234567890 999999999
      The status should be success
      The variable q should equal "123456789135802468038"
    End
  End

  It 'ゼロ除算でエラー(64)になること'
    When call sx_num_divceil_int q 100 0
    The status should equal 64
  End

  It '正符号のゼロ除算でエラー(64)になること'
    When call sx_num_divceil_int q 100 +0
    The status should equal 64
  End

  It '負符号のゼロ除算でエラー(64)になること'
    When call sx_num_divceil_int q 100 -0
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合にエラー(77)になること'
    readonly ro_res_divceil_int="const"
    When call sx_num_divceil_int ro_res_divceil_int 100 3
    The status should equal 77
  End

  It '設定エラー(78)を検知すること'
    check_config() {
      SX_CFG_NUM_RANGE=99
      sx_num_divceil_int q 100 3
    }
    When call check_config
    The status should equal 78
  End

  It '除数を省略した場合は除数1として扱われること'
    When call sx_num_divceil_int q 100
    The status should be success
    The variable q should equal "100"
  End

  It '除数を省略した負数の場合はそのまま扱われること'
    When call sx_num_divceil_int q -100
    The status should be success
    The variable q should equal "-100"
  End

  It '被除数を省略した場合は0として扱われること'
    When call sx_num_divceil_int q
    The status should be success
    The variable q should equal "0"
  End

  It '結果変数名がない場合はエラー(64)になること'
    When call sx_num_divceil_int
    The status should equal 64
  End

  It '無効な変数名の場合はエラー(64)になること'
    When call sx_num_divceil_int 123 100 3
    The status should equal 64
  End

  It '非数値を含む場合はエラー(64)になること'
    When call sx_num_divceil_int q 100 abc
    The status should equal 64
  End
End
