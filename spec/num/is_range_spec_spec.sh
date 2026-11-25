#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_range_spec'
  sxtest_load ./build/modules/sx_num_is_range_spec.sh

  It '単体整数を検証すること'
    When call sx_num_is_range_spec "0" "-1" "+1" "-0" "3" "5" "-5" "+5"
    The status should be success
  End

  It '範囲指定を検証すること'
    When call sx_num_is_range_spec "0:5" "2:5" "-4:-2" "1:-1" "0:0" "0:10" "10:0" "0:-0" "0:+0" "-0:5"
    The status should be success
  End

  It '始点省略の範囲指定を検証すること'
    When call sx_num_is_range_spec ":5" ":0" ":1"
    The status should be success
  End

  It 'step付き範囲指定を検証すること'
    When call sx_num_is_range_spec "0:5:2" "4:0:-2" "1:2:3" "0:5:-1" "1:2:+1" "0:0:1" ":0:1" "-0:-0:-1" "10:20:30" "2147483647:0:-1"
    The status should be success
  End

  It '意味的には空の範囲も形式としては検証すること'
    When call sx_num_is_range_spec "2:2" "3:0" "0:5:-1" "5:-5"
    The status should be success
  End

  It '引数なしで成功すること'
    When call sx_num_is_range_spec
    The status should be success
  End

  It '終点省略を拒否すること'
    When call sx_num_is_range_spec "5:" "2:" "0:"
    The status should be failure
  End

  It '始点と終点の省略を拒否すること'
    When call sx_num_is_range_spec ":"
    The status should be failure
  End

  It '終点省略のstep付き形式を拒否すること'
    When call sx_num_is_range_spec "::2" "::-1" "0::1"
    The status should be failure
  End

  It '空の刻みを拒否すること'
    When call sx_num_is_range_spec "2::" "1:2:"
    The status should be failure
  End

  It 'stepが0の範囲を拒否すること'
    When call sx_num_is_range_spec "0:5:0" "0:5:-0" "0:5:+0"
    The status should be failure
  End

  It '4要素 (:が3つ) を拒否すること'
    When call sx_num_is_range_spec "1:2:3:4" "1:2:3:4:5"
    The status should be failure
  End

  It '数値でない spec を拒否すること'
    When call sx_num_is_range_spec "abc" "1-2" "0~3"
    The status should be failure
  End

  It '前ゼロ付きを拒否すること'
    When call sx_num_is_range_spec "007" "01:2" "1:02:3" "01:2:3" "1:2:01" "1:2:00" "1:2:-01" "1:2:+01" "1:2:003" "00:1" "1:00" "0:01"
    The status should be failure
  End

  It '不正な符号形式を拒否すること'
    When call sx_num_is_range_spec "--1" "+01"
    The status should be failure
  End

  It '空文字列を拒否すること'
    When call sx_num_is_range_spec ""
    The status should be failure
  End

  It '複数引数のうち1つでも無効なら失敗すること'
    When call sx_num_is_range_spec "0:5" "1:5:2" "5:"
    The status should be failure
  End

  It 'SX_CFG_NUM_RANGE が不正でも判定できること'
    check_invalid_config() {
      SX_CFG_NUM_RANGE=99
      sx_num_is_range_spec "0:5:2"
    }
    When call check_invalid_config
    The status should be success
  End

  Context 'SX_CFG_SKIP_CHK が 1 のとき'
    BeforeRun 'SX_CFG_SKIP_CHK=1'

    It '正常な spec で成功すること'
      When call sx_num_is_range_spec "0:5:2"
      The status should be success
    End

    It '無効な spec を拒否すること'
      When call sx_num_is_range_spec "0:5:0"
      The status should be failure
    End
  End
End
