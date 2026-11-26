#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_sh_pos_ref'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_sh_pos_ref.sh

  It '単体整数で 1 から N-1 までの参照を生成すること (0 は除外)'
    When call sx_sh_pos_ref result ' ' 4
    The variable result should eq '"${1}" "${2}" "${3}"'
    The status should be success
  End

  It '開始と終了(exclusive)を指定して参照を生成すること'
    When call sx_sh_pos_ref result ' ' 1:4
    The variable result should eq '"${1}" "${2}" "${3}"'
    The status should be success
  End

  It '開始、終了(exclusive)、増分を指定して参照を生成すること'
    When call sx_sh_pos_ref result ' ' 1:5:2
    The variable result should eq '"${1}" "${3}"'
    The status should be success
  End

  It '開始を省略した slice を解釈すること'
    When call sx_sh_pos_ref result ' ' :4
    The variable result should eq '"${1}" "${2}" "${3}"'
    The status should be success
  End

  It '空の範囲の場合は空文字列を返すこと'
    When call sx_sh_pos_ref result ' ' 0
    The variable result should eq ''
    The status should be success
  End

  It '負の単体整数は空範囲として扱うこと'
    When call sx_sh_pos_ref result ' ' -1
    The variable result should eq ''
    The status should be success
  End

  It '開始が負の範囲を 1 以上にクランプすること'
    When call sx_sh_pos_ref result ' ' -3:4
    The variable result should eq '"${1}" "${2}" "${3}"'
    The status should be success
  End

  It '負の開始と 2 の増分で等差数列を正しくクランプすること'
    When call sx_sh_pos_ref result ' ' -2:4:2
    The variable result should eq '"${2}"'
    The status should be success
  End

  It '負の開始と 2 の増分で 1 から始まる場合に正しくクランプすること'
    When call sx_sh_pos_ref result ' ' -3:4:2
    The variable result should eq '"${1}" "${3}"'
    The status should be success
  End

  It '負の増分で降順の参照を生成すること'
    When call sx_sh_pos_ref result ' ' 5:0:-1
    The variable result should eq '"${5}" "${4}" "${3}" "${2}" "${1}"'
    The status should be success
  End

  It '終点が負でも 1 以上を出力すること'
    When call sx_sh_pos_ref result ' ' 5:-3:-1
    The variable result should eq '"${5}" "${4}" "${3}" "${2}" "${1}"'
    The status should be success
  End

  It '正の終点は降順のクランプで変更しないこと'
    When call sx_sh_pos_ref result ' ' 5:3:-1
    The variable result should eq '"${5}" "${4}"'
    The status should be success
  End

  It '複数の spec を任意の区切り文字で連結すること'
    When call sx_sh_pos_ref result ', ' 0:3 5:7
    The variable result should eq '"${1}", "${2}", "${5}", "${6}"'
    The status should be success
  End

  It '呼び出し元の IFS が空白以外でも区切りどおりに連結すること'
    sxtest_run result -- 'IFS=,; sx_sh_pos_ref result "$@"' ' ' 1:3
    The variable result should eq '"${1}" "${2}"'
  End

  It '空の区切り文字で連結すること'
    When call sx_sh_pos_ref result '' 1:3
    The variable result should eq '"${1}""${2}"'
    The status should be success
  End

  It 'パターン記号を区切り文字として扱えること'
    When call sx_sh_pos_ref result '*' 1:3
    The variable result should eq '"${1}"*"${2}"'
    The status should be success
  End

  It 'メタ文字を区切り文字としてリテラルに保持すること'
    When call sx_sh_pos_ref result '$"' 1:3
    The variable result should eq '"${1}"$""${2}"'
    The status should be success
  End

  It '円記号を区切り文字としてリテラルに保持すること'
    When call sx_sh_pos_ref result '\' 1:3
    The variable result should eq '"${1}"\"${2}"'
    The status should be success
  End

  It '非数値が指定された場合はエラーを返すこと'
    When call sx_sh_pos_ref result ' ' abc
    The status should eq 64
  End

  It '増分(step)に0が指定された場合はエラーを返すこと'
    When call sx_sh_pos_ref result ' ' 1:5:0
    The status should eq 64
  End

  It '開始が空の colon 形式はエラーを返すこと'
    When call sx_sh_pos_ref result ' ' 1::2
    The status should eq 64
  End

  It '符号付き0の増分はエラーを返すこと'
    When call sx_sh_pos_ref result ' ' 1:5:+0
    The status should eq 64
  End

  It '宛先変数名が無効な場合はエラーを返すこと'
    When call sx_sh_pos_ref 1res ' ' 3
    The status should eq 64
  End

  It '引数がない場合はエラーを返すこと'
    When call sx_sh_pos_ref
    The status should eq 64
  End

  It '宛先変数が読み取り専用の場合はエラーを返すこと'
    readonly ro_var=fixed
    When call sx_sh_pos_ref ro_var ' ' 3
    The status should eq 77
  End

  It 'チェック省略時は引数検証を省略すること'
    SX_CFG_SKIP_CHK=1
    When call sx_sh_pos_ref result ',' 1:3
    The status should be success
    The variable result should eq '"${1}","${2}"'
  End

  It 'チェック省略時は複数の spec を処理すること'
    SX_CFG_SKIP_CHK=1
    When call sx_sh_pos_ref result ',' 1:3 5:7
    The status should be success
    The variable result should eq '"${1}","${2}","${5}","${6}"'
  End
End
