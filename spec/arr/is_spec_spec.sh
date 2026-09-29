#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_is_spec'
  Include ./sx.sh

  It '単体指定を検証すること'
    When call sx_arr_is_spec "0" "-1" "+1" "-0" "3"
    The status should be success
  End

  It '範囲指定を検証すること'
    When call sx_arr_is_spec "0:3" "-4:-2" "1:-1" "400:500"
    The status should be success
  End

  It 'step付き範囲指定を検証すること'
    When call sx_arr_is_spec "0:5:2" "4:0:-2" "1:2:3"
    The status should be success
  End

  It '意味的には空の範囲も形式としては検証すること'
    When call sx_arr_is_spec "2:2" "3:0" "0:5:-1"
    The status should be success
  End

  It '終端省略を検証すること'
    When call sx_arr_is_spec "2:" "2::-1" "0:5:2"
    The status should be success
  End

  It '始点省略を検証すること'
    When call sx_arr_is_spec ":5" "::2" "::-1" ":"
    The status should be success
  End

  It '空の刻みを拒否すること'
    When call sx_arr_is_spec "2::" "1:2:"
    The status should be failure
  End

  It '始点のみの省略形を検証すること'
    When call sx_arr_is_spec ":2" "::-1"
    The status should be success
  End

  It '全省略の : を検証すること'
    When call sx_arr_is_spec ":"
    The status should be success
  End

  It '引数なしで成功すること'
    When call sx_arr_is_spec
    The status should be success
  End

  It '- 区切りを拒否すること'
    When call sx_arr_is_spec "1-2"
    The status should be failure
  End

  It '-- を含む形式を拒否すること'
    When call sx_arr_is_spec "-4--2"
    The status should be failure
  End

  It '第二コロンのみの :: を拒否すること'
    When call sx_arr_is_spec "::"
    The status should be failure
  End

  It ':e: 形式の空の刻みを拒否すること'
    When call sx_arr_is_spec ":5:" "1::2:3"
    The status should be failure
  End

  It '旧記法 ~ を拒否すること'
    When call sx_arr_is_spec "0~3" "~"
    The status should be failure
  End

  It 'stepが0の範囲を拒否すること'
    When call sx_arr_is_spec "0:5:0" "0:5:-0" "0:5:+0"
    The status should be failure
  End

  It '4要素 (:が3つ) を拒否すること'
    When call sx_arr_is_spec "1:2:3:4"
    The status should be failure
  End

  It '数値でない spec を拒否すること'
    When call sx_arr_is_spec "abc"
    The status should be failure
  End

  It '前ゼロ付きを拒否すること'
    When call sx_arr_is_spec "007" "0:05"
    The status should be failure
  End

  It '端点欠けを拒否すること'
    When call sx_arr_is_spec "1:" ":2" "1::2" ""
    The status should be failure
  End

  It '複数引数のうち1つでも無効なら失敗すること'
    When call sx_arr_is_spec "0" "1:3" "abc"
    The status should be failure
  End

  It 'SX_CFG_NUM_RANGE が不正でも判定できること'
    check_invalid_config() {
      SX_CFG_NUM_RANGE=99
      sx_arr_is_spec "0:5:2"
    }
    When call check_invalid_config
    The status should be success
  End

  Context 'SX_CFG_SKIP_CHK が 1 のとき'
    BeforeRun 'SX_CFG_SKIP_CHK=1'

    It '正常な spec で成功すること'
      When call sx_arr_is_spec "0:5:2"
      The status should be success
    End

    It '無効な spec を拒否すること'
      When call sx_arr_is_spec "0:5:0"
      The status should be failure
    End
  End
End
