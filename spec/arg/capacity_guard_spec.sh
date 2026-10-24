#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は補助処理用シェルで展開する。

eval "$(shellspec - -c) exit 1"

Describe '可変長 sx_arg_* の引数個数ガード'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_arg_len)
        sxtest_load ./build/modules/sx_arg_len.sh
        ;;
      sx_arg_map)
        sxtest_load ./build/modules/sx_arg_map.sh
        ;;
      sx_arg_pad)
        sxtest_load ./build/modules/sx_arg_pad.sh
        ;;
      __sx_var_copy_script)
        sxtest_load ./build/modules/__sx_var_copy_script.sh
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/run.sh

  Describe 'sx_arg_len'
    It 'SX_CFG_NUM_RANGE が不正な値の場合に EX_CONFIG を返すこと'
      load_subject sx_arg_len
      SX_CFG_NUM_RANGE=bogus
      When call sx_arg_len res "v1" "v2"
      The status should equal 78
    End

    It '高速モード (SX_CFG_SKIP_CHK=1) ではガードをバイパスすること'
      load_subject sx_arg_len
      SX_CFG_SKIP_CHK=1
      SX_CFG_NUM_RANGE=bogus
      When call sx_arg_len res "v1" "v2" "v3"
      The status should be success
      The variable res should equal 3
    End

    It '安全範囲内の引数個数であれば従来どおり成功すること'
      load_subject sx_arg_len
      When call sx_arg_len res "v1" "v2" "v3" "v4" "v5"
      The status should be success
      The variable res should equal 5
    End
  End

  Describe 'sx_arg_map'
    It '引数個数が安全範囲外でも変換すること'
      load_subject sx_arg_map
      # shellcheck disable=SC2329
      __sx_num_is_nat0_safe() { [ "${1}" -ge 3 ] && return 1; return 0; }
      # shellcheck disable=SC2329
      cb() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=${3}:${2}"; }
      When call sx_arg_map res cb "v1" "v2"
      The status should be success
      The variable res should equal '1:v1 2:v2'
    End
  End

  Describe 'sx_arg_pad'
    It '引数個数が安全範囲外でも元の値をクォートすること'
      load_subject sx_arg_pad
      __sx_num_is_nat0_safe() { [ "${1}" -ge 3 ] && return 1; return 0; }
      When call sx_arg_pad res ::: "v1" "v2"
      The status should be success
      The variable res should equal "'v1' 'v2'"
    End
  End

  Describe '内部呼び出し (__sx_var_copy_script)'
    It '有効な連鎖式でコピースクリプト生成が成功すること'
      load_subject __sx_var_copy_script
      When call __sx_var_copy_script out "a=b" "c=d"
      The status should be success
      The variable out should include "__sx_var_unset a"
      The variable out should include "unset -v a"
      The variable out should include "__sx_var_unset c"
      The variable out should include "unset -v c"
    End
  End
End
