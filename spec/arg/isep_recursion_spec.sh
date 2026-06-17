# shellcheck shell=sh

Describe 'sx_arg_isep (recursion support)'
  Include ./sx.sh

  Describe 'Forward Callback Recursion'
    inner_cb() { __sx_var_set "${1}=>"; }
    outer_cb() {
      _o_var="${1}" _o_cnt="${2}"
      if [ "${_o_cnt}" = "1" ]; then
        sx_arg_isep inner_res inner_cb 1 "" "$SX_ARG_ISEP_CB" ::: "A" "B"
        __sx_var_set "${_o_var}=<${inner_res}>"
      else
        __sx_var_set "${_o_var}=[${_o_cnt}]"
      fi
      unset _o_var _o_cnt
    }

    It 'コールバック内で sx_arg_isep を再帰的に呼び出した場合の挙動確認'
      When call sx_arg_isep res outer_cb 1 "" "$SX_ARG_ISEP_CB" ::: "1" "2" "3"
      
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "1"
      The value "$2" should equal "<'A' '>' 'B'>"
      The value "$3" should equal "2"
      The value "$4" should equal "[2]"
      The value "$5" should equal "3"
      The value "$#" should equal 5
    End
  End

  Describe 'Backward Callback Recursion'
    inner_cb_back() { __sx_var_set "${1}=>"; }
    outer_cb_back() {
      _ob_var="${1}" _ob_cnt="${2}"
      if [ "${_ob_cnt}" = "1" ]; then
        sx_arg_isep inner_res inner_cb_back -1 "" "$SX_ARG_ISEP_CB" ::: "X" "Y"
        __sx_var_set "${_ob_var}=<${inner_res}>"
      else
        __sx_var_set "${_ob_var}=[${_ob_cnt}]"
      fi
      unset _ob_var _ob_cnt
    }

    It 'コールバック内で sx_arg_isep を再帰的に呼び出した場合の挙動確認 (Backward)'
      When call sx_arg_isep res outer_cb_back -1 "" "$SX_ARG_ISEP_CB" ::: "1" "2"
      
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "1"
      The value "$2" should equal "<'X' '>' 'Y'>"
      The value "$3" should equal "2"
      The value "$#" should equal 3
    End
  End

  Describe '3段階ネスト再帰'
    innermost_cb() { __sx_var_set "${1}=inner"; }
    middle_cb() {
      _m_var="${1}" _m_cnt="${2}"
      if [ "${_m_cnt}" = "1" ]; then
        sx_arg_isep innermost_res innermost_cb 1 "" "$SX_ARG_ISEP_CB" ::: "Z" "W"
        __sx_var_set "${_m_var}=inner_done"
      else
        __sx_var_set "${_m_var}=m${_m_cnt}"
      fi
      unset _m_var _m_cnt innermost_res
    }
    outer_cb_deep() {
      _od_var="${1}" _od_cnt="${2}"
      if [ "${_od_cnt}" = "1" ]; then
        sx_arg_isep middle_res middle_cb 1 "" "$SX_ARG_ISEP_CB" ::: "X" "Y"
        __sx_var_set "${_od_var}=middle_done"
      else
        __sx_var_set "${_od_var}=o${_od_cnt}"
      fi
      unset _od_var _od_cnt middle_res
    }

    It '外側→中間→最内の3段階ネスト (全て Forward)'
      When call sx_arg_isep res outer_cb_deep 1 "" "$SX_ARG_ISEP_CB" ::: "1" "2" "3"
      
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "1"
      The value "$2" should equal "middle_done"
      The value "$3" should equal "2"
      The value "$4" should equal "o2"
      The value "$5" should equal "3"
      The value "$#" should equal 5
    End
  End

  Describe '混在方向ネスト再帰 (Forward → Backward)'
    inner_cb_mixed() { __sx_var_set "${1}=CB"; }
    outer_cb_mixed() {
      _om_var="${1}" _om_cnt="${2}"
      if [ "${_om_cnt}" = "1" ]; then
        sx_arg_isep inner_res_mixed inner_cb_mixed -1 "" "$SX_ARG_ISEP_CB" ::: "P" "Q"
        __sx_var_set "${_om_var}=mixed_done"
      else
        __sx_var_set "${_om_var}=[${_om_cnt}]"
      fi
      unset _om_var _om_cnt inner_res_mixed
    }

    It '外側 Forward → 内側 Backward で正しく動作すること'
      When call sx_arg_isep res outer_cb_mixed 1 "" "$SX_ARG_ISEP_CB" ::: "1" "2"
      
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "1"
      The value "$2" should equal "mixed_done"
      The value "$3" should equal "2"
      The value "$#" should equal 3
    End
  End

  Describe '再帰内エラー伝搬'
    inner_cb_err() { __sx_var_set "${1}=ERR"; return 42; }

    It '内側の CB エラーが外側に影響しないこと'
      inner_res_err=
      cb_err_recurse() {
        _e_var="${1}" _e_cnt="${2}"
        if [ "${_e_cnt}" = "1" ]; then
          sx_arg_isep inner_res_err inner_cb_err 1 "" "$SX_ARG_ISEP_CB" ::: "A" "B"
          __sx_var_set "${_e_var}=err_handled"
        else
          __sx_var_set "${_e_var}=[${_e_cnt}]"
        fi
        unset _e_var _e_cnt inner_res_err
      }
      When call sx_arg_isep res cb_err_recurse 1 "" "$SX_ARG_ISEP_CB" ::: "1" "2" "3"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "1"
      The value "$2" should equal "err_handled"
      The value "$3" should equal "2"
      The value "$4" should equal "[2]"
      The value "$5" should equal "3"
      The value "$#" should equal 5
    End
  End
End
