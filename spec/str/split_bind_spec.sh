#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_split bind'
  Include ./spec/support/library.sh spec/str/split_bind_spec.sh SX_STR_SPLIT_GLOB SX_STR_SPLIT_INC __sx_arg_isep __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_num_sub_nat0 __sx_str_chunk __sx_var_bind __sx_var_bind0 sx_cfg_set sx_str_split

  It '前方分割でバインドができること'
    When call sx_str_split "a:b:rem" "v1:v2:v3:v4" ":"
    The status should be success
    The variable a should equal "v1"
    The variable b should equal "v2"
    The variable rem should equal "'v3' 'v4'"
  End

  It '後方分割でバインドができること'
    When call sx_str_split "rem:c:d" "v1:v2:v3:v4" ":" -2
    The status should be success
    The variable c should equal "v3"
    # 最後の変数は常にクォートされたリストになる
    The variable d should equal "'v4'"
    # 途中の変数は生の値になる
    The variable rem should equal "v1:v2"
  End

  It '空区切り（文字単位）でバインドができること'
    # 境界線モデル: '' 'a' 'b' 'c' ''
    When call sx_str_split "a:b:c:rem" "abc" ""
    The status should be success
    The variable a should equal ""
    The variable b should equal "a"
    The variable c should equal "b"
    # 最後の変数は残りのリスト ('c' '')
    The variable rem should equal "'c' ''"
  End

  It 'セパレータを含める場合にバインドができること'
    # limit=0 は分割なし。文字列全体が第1変数に代入されるが、
    # スキーマに : があるため、a は「途中」扱いとなり生の値が入る。
    When call sx_str_split "a:rem" "v1:v2" ":" 0
    The status should be success
    The variable a should equal "v1:v2"
    The variable rem should equal ""
  End

  It 'グロブ分割でバインドができること'
    # limit=0 は分割なし。
    When call sx_str_split "a:b:rem" "v1:v2;v3" "[:;]" 0 "${SX_STR_SPLIT_GLOB}"
    The status should be success
    The variable a should equal "v1:v2;v3"
    The variable b should be undefined
    The variable rem should equal ""
  End

  Context 'バインド先をちょうど使い切る場合'
    Parameters
      0 'head:' abc '' 3 0 '' 2
      1 'head:' abc '' 3 0 '' 2
      0 'head:' abc '' -1 0 abc 2
      1 'head:' abc '' -3 0 a 2
      0 '2head:' abc '' 3 0 "'' 'a'" 3
      1 '2head:' abc '' 3 2 "'' ''" 2
      0 '2head:' abc '' -2 2 "'ab' ''" 2
      1 'head:' 'a:b:c' : 2 0 a 2
      0 '2head:' 'a:b:c' : 2 2 "'a' ':'" 2
      1 'head:' a1b2c '[0-9]' 2 1 a 2
      0 '2head:' a1b2c '[0-9]' 2 3 "'a' '1'" 2
    End

    It '枯渇検出のバインド呼び出しを最大一回で打ち切り成功終了すること'
      sx_cfg_set "SKIP_CHK=$1"
      bind_calls=0
      # shellcheck disable=SC2329
      __sx_var_bind() {
        bind_calls=$((bind_calls + 1))
        __sx_var_bind0 1 "$@"
      }
      __sx_str_chunk() { return 64; }
      __sx_arg_isep() { return 64; }
      When call sx_str_split "$2" "$3" "$4" "$5" "$6"
      The status should be success
      The variable head should equal "$7"
      The variable bind_calls should equal "$8"
    End
  End

  Context '先頭の一要素だけ取得する場合'
    Parameters
      abc '' 3 0 '' 1
      abc '' -1 2 abc 1
      abc '' -999999999999999999999999 0 '' 1
      'a:b:c' : 3 0 a 1
      a1b2c '[0-9]' 3 3 a 0
    End

    It '先頭の一要素だけ取得する場合に減算回数が最大一回にとどまること'
      counter_updates=0
      # 後方分割では、先頭部分を確定する準備の減算も一回として数える。
      # shellcheck disable=SC2329
      __sx_num_sub1_arith() {
        counter_updates=$((counter_updates + 1))
        __sx_num_sub_nat0 "$1" "$2" 1
      }
      # shellcheck disable=SC2329
      __sx_num_sub1_nat0() {
        counter_updates=$((counter_updates + 1))
        __sx_num_sub_nat0 "$1" "$2" 1
      }
      When call sx_str_split 'head:' "$1" "$2" "$3" "$4"
      The status should be success
      The variable head should equal "$5"
      The variable counter_updates should equal "$6"
    End
  End

  Context '空のバインド指定'
    Parameters
      0 abc '' -2 2
      1 abc '' -2 2
      0 abc '' '' 2
      1 abc '' 2 0
      0 '' '' -999999999999999999999999 2
      1 '' '' 0 2
      0 a:b:c : '' 2
      1 a:b:c : 2 0
      0 a:b:c : -2 2
      1 a1b2c '[0-9]' '' 3
      0 a1b2c '[0-9]' -2 3
      1 abc '***' -2 3
    End

    It '検査の有無・方向・区切り・INCによらず出力せず正常終了すること'
      sx_cfg_set "SKIP_CHK=$1"
      res=old
      # 準備関数の呼び出し有無は制約せず、実際の関数で空bindの動作を検証する。
      When call sx_str_split '' "$2" "$3" "$4" "$5"
      The status should be success
      The output should be blank
      The error should be blank
      The variable res should equal old
    End
  End

  It '空区切りのINCで空要素をスキップできること'
    When call sx_str_split '::head:rest' abc '' '' "$SX_STR_SPLIT_INC"
    The status should be success
    The variable head should equal a
    The variable rest should equal "'' 'b' '' 'c' '' ''"
  End

  It '同名の蓄積先への複数回の割当を保持すること'
    When call sx_str_split '2v:1v:rest' abc ''
    The status should be success
    The variable v should equal "'' 'a' 'b'"
    The variable rest should equal "'c' ''"
  End

  It '任意桁のバインド個数を指定して空要素を含めて蓄積できること'
    When call sx_str_split '999999999999999999999999v:' abc ''
    The status should be success
    The variable v should equal "'' 'a' 'b' 'c' ''"
  End

  It '空区切りの結果を配列と残りのリストに分配できること'
    When call sx_str_split '2@arr:rest' abc ''
    The status should be success
    The variable arr_len should equal 2
    The variable arr_0 should equal ''
    The variable arr_1 should equal a
    The variable rest should equal "'b' 'c' ''"
  End

  It 'INCの空区切りを配列にも独立した要素として格納すること'
    When call sx_str_split '2@arr:rest' abc '' '' "$SX_STR_SPLIT_INC"
    The status should be success
    The variable arr_len should equal 2
    The variable arr_0 should equal ''
    The variable arr_1 should equal ''
    The variable rest should equal "'a' '' 'b' '' 'c' '' ''"
  End

  Context '空区切りのメタ文字'
    Parameters
      # shellcheck disable=SC2286
      ''
      # shellcheck disable=SC2215
      -999999999999999999999999
    End

    It '引用符・空白・glob文字・ドル記号を生の値として分配できること'
      When call sx_str_split 'a:b:c:d:e:f:g:h:' "a' *?$" '' "$1"
      The status should be success
      The variable a should equal ''
      The variable b should equal a
      The variable c should equal "'"
      The variable d should equal ' '
      The variable e should equal '*'
      The variable f should equal '?'
      The variable g should equal '$'
      The variable h should equal ''
    End
  End

  It 'バインド変数が余る場合、余った変数は空（最後の変数）または未設定になること'
    v1=old v2=old v3=old
    When call sx_str_split "v1:v2:v3" "a" ":"
    The status should be success
    The variable v1 should equal "a"
    The variable v2 should be undefined
    # bind_init は最後の変数を "" で初期化する
    The variable v3 should equal ""
  End
End
