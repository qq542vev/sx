#!/bin/sh

Describe 'sx_num_to_fixed'
  Include ./sx.sh

  It '正の指数を正しく変換すること'
    sx_num_to_fixed res="1.2e+3"
    The variable res should equal "1200"
    
    sx_num_to_fixed res="1.234E2"
    The variable res should equal "123.4"
  End

  It '負の指数を正しく変換すること'
    sx_num_to_fixed res="1.2e-3"
    The variable res should equal "0.0012"
    
    sx_num_to_fixed res="123.45e-1"
    The variable res should equal "12.345"
  End

  It '符号付き数値を正しく扱うこと'
    sx_num_to_fixed res="-1.2e+2"
    The variable res should equal "-120"
    
    sx_num_to_fixed res="+1.2e-1"
    The variable res should equal "0.12"
  End

  It '整数や既に固定小数点形式のものをそのまま返すこと'
    sx_num_to_fixed res="123"
    The variable res should equal "123"
    
    sx_num_to_fixed res="0.001"
    The variable res should equal "0.001"
  End

  It '極端なケースを処理すること'
    sx_num_to_fixed res="0e0"
    The variable res should equal "0"
    
    sx_num_to_fixed res="1e-5"
    The variable res should equal "0.00001"
  End

  It '一括変換ができること'
    sx_num_to_fixed r1="1.2e3" r2="4.5e-1"
    The variable r1 should equal "1200"
    The variable r2 should equal "0.45"
  End

  It '不正な入力に対してエラーを返すこと (変数形式)'
    When call sx_num_to_fixed res="abc"
    The status should equal 64
  End

  It '不正な入力に対してエラーを返すこと (単独数値形式はサポート外1)'
    When call sx_num_to_fixed "1.2e3"
    The status should equal 64
  End

  It '不正な入力に対してエラーを返すこと (単独数値形式はサポート外2)'
    When call sx_num_to_fixed "abc"
    The status should equal 64
  End

  It '読み取り専用変数に対してエラーを返すこと'
    readonly ro_var=1
    When call sx_num_to_fixed ro_var="1.2e3"
    The status should equal 77
  End
End
