#!/bin/sh

Describe 'sx_glob_esc_eq'
  sxtest_load ./build/modules/sx_glob_esc_eq.sh

  Context '変換結果'
    Parameters
      'cafe' ae '' 'c[[=a=]]f[[=e=]]'
      '=＝' '=＝' '' '[[===]][[=＝=]]'
      '*?[' '' '' '[*][?][[]'
      '\' '' '' '[\\]'
      'a+b' '' '+' 'a[+]b'
    End

    It '指定文字を等価クラスにし、glob 特殊文字と追加文字をリテラル化する'
      When call sx_glob_esc_eq result "$1" "$2" "$3"
      The status should be success
      The variable result should equal "$4"
    End
  End

  It '等価クラス化する文字が入力になくても glob 特殊文字をエスケープする'
    When call sx_glob_esc_eq result '*' a
    The status should be success
    The variable result should equal '[*]'
  End

  It '追加エスケープ文字が入力になくても glob 特殊文字をエスケープする'
    When call sx_glob_esc_eq result '*' '' +
    The status should be success
    The variable result should equal '[*]'
  End

  It '等価クラス化を既定の glob エスケープと追加エスケープより優先する'
    When call sx_glob_esc_eq result '*!' '*!' '*!'
    The status should be success
    The variable result should equal '[[=*=]][[=!=]]'
  End

  It 'glob 構文文字も等価クラス化し、生成パターンでリテラル照合できる'
    LC_ALL=C
    input='*?[]\' result=''
    When call sx_glob_esc_eq result "$input" '*?[]\'
    The status should be success
    The variable result should equal '[[=*=]][[=?=]][[=[=]][[=]=]][[=\=]]'
    The variable input should match pattern "$result"
    probe=abc
    The variable probe should not match pattern "$result"
  End

  It '追加文字の !、^、] を case パターンでリテラル照合できる'
    input='a!^]' result=''
    When call sx_glob_esc_eq result "$input" '' '!^]'
    The status should be success
    The variable result should equal 'a[[.!.]][[.^.]][]]'
    The variable input should match pattern "$result"
  End

  It '入力と結果変数が同じでも変換できる'
    result='a*='
    When call sx_glob_esc_eq result "$result" '='
    The status should be success
    The variable result should equal 'a[*][[===]]'
  End

  It '文字列と等価クラス化する文字を省略すると空文字列を設定する'
    result=previous
    When call sx_glob_esc_eq result
    The status should be success
    The variable result should equal ''
  End

  It '引用符・ドル記号・改行をデータとして保持する'
    input="a'\"\$\`;
b" expected="a'\"\$\`;
b"
    When call sx_glob_esc_eq result "$input"
    The status should be success
    The variable result should equal "$expected"
  End

  Context '結果変数名の検証'
    Parameters
      ''
      1result
      'result:count'
      'result;bad'
    End

    It '不正な結果変数名を拒否する'
      result=previous
      When call sx_glob_esc_eq "$1" abc
      The status should equal 64
      The variable result should equal previous
    End
  End

  It '結果変数名の省略を拒否する'
    When call sx_glob_esc_eq
    The status should equal 64
  End

  It '読み取り専用の結果変数を拒否する'
    readonly MYRO_GE_EQ=previous
    When call sx_glob_esc_eq MYRO_GE_EQ abc
    The status should equal 77
    The variable MYRO_GE_EQ should equal previous
  End

  It '不正な設定値を拒否し、結果変数を保持する'
    SX_CFG_NUM_RANGE=invalid
    result=previous
    When call sx_glob_esc_eq result abc
    The status should equal 78
    The variable result should equal previous
  End

  It '未設定の設定値を拒否し、結果変数を保持する'
    unset SX_CFG_NUM_RANGE
    result=previous
    When call sx_glob_esc_eq result abc
    The status should equal 78
    The variable result should equal previous
  End
End

Describe '__sx_glob_esc_eq'
  sxtest_load ./build/modules/__sx_glob_esc_eq.sh

  It '内部モジュール単独でも等価クラスを生成する'
    When call __sx_glob_esc_eq result 'a*=' '='
    The status should be success
    The variable result should equal 'a[*][[===]]'
  End
End
