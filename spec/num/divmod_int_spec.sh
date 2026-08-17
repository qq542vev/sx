#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_divmod_int'
  Include ./sx.sh

  # ホストの算術展開が 64bit 未満か判定する（32bit ホストでは 2^31 超の演算が致命的 overflow になるため）
  arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }

  It '小さな数の除算ができること（あまりなし）'
    When call sx_num_divmod_int "q:r:" 100 4
    The status should be success
    The variable q should equal "25"
    The variable r should equal "0"
  End

  It '小さな数の除算ができること（あまりあり）'
    When call sx_num_divmod_int "q:r:" 100 3
    The status should be success
    The variable q should equal "33"
    The variable r should equal "1"
  End

  It '被除数が除数より小さい場合の除算ができること'
    When call sx_num_divmod_int "q:r:" 5 10
    The status should be success
    The variable q should equal "0"
    The variable r should equal "5"
  End

  It '被除数と除数が等しい場合の除算ができること'
    When call sx_num_divmod_int "q:r:" 42 42
    The status should be success
    The variable q should equal "1"
    The variable r should equal "0"
  End

  It '被除数が0の場合の除算ができること'
    When call sx_num_divmod_int "q:r:" 0 42
    The status should be success
    The variable q should equal "0"
    The variable r should equal "0"
  End

  It '正の被除数を負の除数で除算できること'
    When call sx_num_divmod_int "q:r:" 7 -2
    The status should be success
    The variable q should equal "-3"
    The variable r should equal "1"
  End

  It '負の被除数を正の除数で除算できること'
    When call sx_num_divmod_int "q:r:" -7 2
    The status should be success
    The variable q should equal "-3"
    The variable r should equal "-1"
  End

  It '負の被除数を負の除数で除算できること'
    When call sx_num_divmod_int "q:r:" -7 -2
    The status should be success
    The variable q should equal "3"
    The variable r should equal "-1"
  End

  It '余りが0になる負を含む除算ができること'
    When call sx_num_divmod_int "q:r:" -42 42
    The status should be success
    The variable q should equal "-1"
    The variable r should equal "0"
  End

  It '余りが0になる正の被除数と負の除数の除算ができること'
    When call sx_num_divmod_int "q:r:" 42 -42
    The status should be success
    The variable q should equal "-1"
    The variable r should equal "0"
  End

  It '余りが0になる負の被除数と負の除数の除算ができること'
    When call sx_num_divmod_int "q:r:" -42 -42
    The status should be success
    The variable q should equal "1"
    The variable r should equal "0"
  End

  It '負の多倍長整数を除算できること'
    When call sx_num_divmod_int "q:r:" -192837465564738291019283746 987654321012
    The status should be success
    The variable q should equal "-195247933879484"
    The variable r should equal "-649962365938"
  End

  It '正の多倍長整数を負の除数で除算できること'
    When call sx_num_divmod_int "q:r:" 192837465564738291019283746 -987654321012
    The status should be success
    The variable q should equal "-195247933879484"
    The variable r should equal "649962365938"
  End

  It '被除数が0で負の除数の場合の除算ができること'
    When call sx_num_divmod_int "q:r:" 0 -5
    The status should be success
    The variable q should equal "0"
    The variable r should equal "0"
  End

  It '被除数に符号付きゼロを指定した場合の除算ができること'
    When call sx_num_divmod_int "q:r:" -0 42
    The status should be success
    The variable q should equal "0"
    The variable r should equal "0"
  End

  Context '64ビット設定'
    Before 'SX_CFG_NUM_RANGE=64'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64

    It '負の多倍長整数を高速パス5で除算できること'
      When call sx_num_divmod_int "q:r:" -123456789012345678901234567890 999999999
      The status should be success
      The variable q should equal "-123456789135802468037"
      The variable r should equal "-37035927"
    End
  End

  It 'ゼロ除算でエラー(64)になること'
    When call sx_num_divmod_int "q:r:" 100 0
    The status should equal 64
  End

  It '正符号付きゼロの除算でエラー(64)になること'
    When call sx_num_divmod_int "q:r:" 100 +0
    The status should equal 64
  End

  It '負符号付きゼロの除算でエラー(64)になること'
    When call sx_num_divmod_int "q:r:" 100 -0
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合にエラー(77)になること'
    readonly ro_res_int_divmod="const"
    When call sx_num_divmod_int "ro_res_int_divmod:r:" 100 4
    The status should equal 77
  End

  It '設定エラー(78)を検知すること'
    check_config() {
      SX_CFG_NUM_RANGE=99
      sx_num_divmod_int "q:r:" 100 4
    }
    When call check_config
    The status should equal 78
  End

  It '除数を省略した場合は除数1として扱われること'
    When call sx_num_divmod_int "q:r:" 100
    The status should be success
    The variable q should equal "100"
    The variable r should equal "0"
  End

  It '負の被除数で除数を省略した場合の除算ができること'
    When call sx_num_divmod_int "q:r:" -7
    The status should be success
    The variable q should equal "-7"
    The variable r should equal "0"
  End

  It '非数値を含む場合はエラー(64)になること'
    When call sx_num_divmod_int "q:r:" 100 abc
    The status should equal 64
  End
End