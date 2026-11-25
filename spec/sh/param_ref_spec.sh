#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_sh_param_ref'
  sxtest_load ./build/modules/sx_sh_param_ref.sh

  restore_ref() {
    eval "set -- ${1}"
    restored="${#}:${1}:${2}"
  }

  It '複数の変数参照を半角空白で結合すること'
    When call sx_sh_param_ref res ' ' a b c
    The status should be success
    The variable res should equal '"${a}" "${b}" "${c}"'
  End

  It '位置パラメータの参照を生成すること'
    When call sx_sh_param_ref res ' ' 1 2 3
    The status should be success
    The variable res should equal '"${1}" "${2}" "${3}"'
  End

  It '特殊パラメータの参照を生成すること'
    When call sx_sh_param_ref res ' ' @ '*' '#' '?' '-' '$' '!'
    The status should be success
    The variable res should equal '"${@}" "${*}" "${#}" "${?}" "${-}" "${$}" "${!}"'
  End

  It '任意の区切り文字で結合すること'
    When call sx_sh_param_ref res ', ' a b
    The status should be success
    The variable res should equal '"${a}", "${b}"'
  End

  It '空の区切り文字で結合すること'
    When call sx_sh_param_ref res '' a b
    The status should be success
    The variable res should equal '"${a}""${b}"'
  End

  It 'パターン記号を区切り文字として扱えること'
    When call sx_sh_param_ref res '*' a b
    The status should be success
    The variable res should equal '"${a}"*"${b}"'
  End

  It 'パラメータが1つの場合は区切り文字を含めないこと'
    When call sx_sh_param_ref res ', ' a
    The status should be success
    The variable res should equal '"${a}"'
  End

  It '生成した参照を eval で復元できること'
    a='alpha beta' b=gamma
    sx_sh_param_ref ref ' ' a b
    When call restore_ref "${ref}"
    The status should be success
    The variable restored should equal '2:alpha beta:gamma'
  End

  It 'パラメータがない場合は空文字列を格納すること'
    When call sx_sh_param_ref res ' '
    The status should be success
    The variable res should equal ''
  End

  It '結果変数名が無効な場合に EX_USAGE を返すこと'
    When call sx_sh_param_ref 1res ' ' a
    The status should equal 64
  End

  It 'パラメータが無効な場合に EX_USAGE を返すこと'
    When call sx_sh_param_ref res ' ' 'a-b'
    The status should equal 64
  End

  It '空のパラメータが指定された場合に EX_USAGE を返すこと'
    When call sx_sh_param_ref res ' ' ''
    The status should equal 64
  End

  It '引数がない場合に EX_USAGE を返すこと'
    When call sx_sh_param_ref
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_param_ref=fixed
    When call sx_sh_param_ref ro_param_ref ' ' a
    The status should equal 77
  End

  It 'チェック省略時は引数検証を省略すること'
    SX_CFG_SKIP_CHK=1
    When call sx_sh_param_ref res ',' 'a-b'
    The status should be success
    The variable res should equal '"${a-b}"'
  End
End
