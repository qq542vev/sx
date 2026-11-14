# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
Describe 'sx_str_len -efu 環境検証'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_str_len.sh

  It '正常動作'
    When run efu_run sx_str_len 'v1:v2:v3' 'abc' 'de' 'fghij'
    The status should be success
  End

  It '空のバインドでは成功すること'
    When run efu_run sx_str_len '' 'abc' 'de'
    The status should be success
  End

  It '文字列を指定しない場合は成功すること'
    When run efu_run sx_str_len 'v1:v2'
    The status should be success
  End

  It 'バインド先より文字列が多い場合は成功すること'
    When run efu_run sx_str_len 'v1' 'a' 'bb' 'ccc'
    The status should be success
  End

  It '不正なバインド形式の場合は 64 を返すこと'
    When run efu_run sx_str_len 'invalid!' 'abc'
    The status should equal 64
  End
End
