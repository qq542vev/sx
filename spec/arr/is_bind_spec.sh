#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_is_bind'
  Include ./sx.sh

  It '基本的なバインドを検証すること'
    When call sx_arr_is_bind "a:b:c"
    The status should be success
  End

  It 'スキップ（空の要素）を含むバインドを検証すること'
    When call sx_arr_is_bind "a::c" ":b" "a:" "::"
    The status should be success
  End

  It '単一の変数名をバインドとして検証すること'
    When call sx_arr_is_bind "myvar" "_"
    The status should be success
  End

  It '空文字列をバインドとして検証すること'
    When call sx_arr_is_bind ""
    The status should be success
  End

  It '引数なしで成功すること'
    When call sx_arr_is_bind
    The status should be success
  End

  It '数値プレフィックス付きバインドを検証すること'
    When call sx_arr_is_bind "1a:b" "2a:x" "a:2b:c"
    The status should be success
  End

  It '裸のカウンタを許可すること'
    When call sx_arr_is_bind "a:2:b"
    The status should be success
  End

  It '無効な文字（ハイフンなど）を拒否すること'
    When call sx_arr_is_bind "a-b:c"
    The status should be failure
  End

  It '末尾の要素が数字で始まる場合は拒否すること'
    When call sx_arr_is_bind "a:2b" "3" "2b"
    The status should be failure
  End

  It 'その他の無効な文字を拒否すること'
    When call sx_arr_is_bind "a.b" "a=b" "a b" "!"
    The status should be failure
  End

  It '先頭に 0 を持つカウントを拒否すること'
    When call sx_arr_is_bind "0:" "a:0:b" "01a:b"
    The status should be failure
  End

  It '複数引数のうち1つでも無効なら失敗すること'
    When call sx_arr_is_bind "a:b" "0a"
    The status should be failure
  End

  Describe '@ を含む形式の拒否'
    It 'bare @name を拒否すること'
      When call sx_arr_is_bind "@arr"
      The status should be failure
    End

    It 'scalar:@name を拒否すること'
      When call sx_arr_is_bind "a:@arr"
      The status should be failure
    End

    It 'N@name 形式を拒否すること'
      When call sx_arr_is_bind "2@a:x" "a:10@arr:rest"
      The status should be failure
    End

    It '複数引数で @ を含む場合に拒否すること'
      When call sx_arr_is_bind "a:b" "@arr"
      The status should be failure
    End
  End

  It 'SX_CFG_NUM_RANGE が不正でも判定できること'
    check_invalid_config() {
      SX_CFG_NUM_RANGE=99
      sx_arr_is_bind "a:b:c"
    }
    When call check_invalid_config
    The status should be success
  End

  Context 'SX_CFG_SKIP_CHK が 1 のとき'
    BeforeRun 'SX_CFG_SKIP_CHK=1'

    It '正常なバインドで成功すること'
      When call sx_arr_is_bind "a:b:c"
      The status should be success
    End

    It '@ を含む形式を拒否すること'
      When call sx_arr_is_bind "a:@arr"
      The status should be failure
    End
  End
End
