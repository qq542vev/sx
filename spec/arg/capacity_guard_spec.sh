#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '可変長 sx_arg_* の引数個数ガード'
  Include ./sx.sh

  Describe 'sx_arg_len'
    It '引数個数が安全範囲（SX_CFG_NUM_RANGE）外の場合に EX_USAGE を返すこと'
      __sx_num_is_nat0_safe() { [ "${1}" -ge 3 ] && return 1; return 0; }
      When call sx_arg_len res "v1" "v2" "v3"
      The status should equal 64
    End

    It 'SX_CFG_NUM_RANGE が不正な値の場合に EX_CONFIG を返すこと'
      SX_CFG_NUM_RANGE=bogus
      When call sx_arg_len res "v1" "v2"
      The status should equal 78
    End

    It '高速モード (SX_CFG_SKIP_CHK=1) ではガードをバイパスすること'
      SX_CFG_SKIP_CHK=1
      SX_CFG_NUM_RANGE=bogus
      When call sx_arg_len res "v1" "v2" "v3"
      The status should be success
      The variable res should equal 3
    End

    It '安全範囲内の引数個数であれば従来どおり成功すること'
      When call sx_arg_len res "v1" "v2" "v3" "v4" "v5"
      The status should be success
      The variable res should equal 5
    End
  End

  Describe 'sx_arg_map'
    It '引数個数が安全範囲外の場合に他のチェックより先に EX_USAGE を返すこと'
      __sx_num_is_nat0_safe() { [ "${1}" -ge 3 ] && return 1; return 0; }
      When call sx_arg_map res cb "v1" "v2"
      The status should equal 64
    End
  End

  Describe 'sx_arg_pad'
    It '引数個数が安全範囲外の場合に他のチェックより先に EX_USAGE を返すこと'
      __sx_num_is_nat0_safe() { [ "${1}" -ge 3 ] && return 1; return 0; }
      When call sx_arg_pad res ::: "v1" "v2"
      The status should equal 64
    End
  End

  Describe '内部呼び出し (__sx_var_list_copy)'
    It 'コピー用リスト生成が内部版 rquote を利用して従来どおり成功すること'
      When call __sx_var_list_copy out "a=b c=d"
      The status should be success
      The variable out should equal "c=d b=c a=b"
    End
  End
End
