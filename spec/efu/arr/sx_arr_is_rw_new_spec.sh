Describe '__sx_arr_is_rw_new -efu 環境検証'
  Include ./sx.sh

  # テスト対象関数は sx.sh に未収録のため、m4 展開後の生成コードを直接定義する。
  __sx_arr_is_rw_new() {
    __sx_arr_is_rw_new_ro_="${SX_STR_LF}$(readonly -p)${SX_STR_LF}"
    __sx_arr_is_rw_new_out_=

    for __sx_arr_is_rw_new_arg_ in "${@}"; do
      __sx_arr_is_rw_new_rest_="${__sx_arr_is_rw_new_ro_}"

      while case "${__sx_arr_is_rw_new_rest_}" in *"${SX_STR_LF}readonly ${__sx_arr_is_rw_new_arg_}"*);; *) ! :;; esac; do
        __sx_arr_is_rw_new_rest_="${__sx_arr_is_rw_new_rest_#*"${SX_STR_LF}readonly ${__sx_arr_is_rw_new_arg_}"}"

        case "${__sx_arr_is_rw_new_rest_}" in
          [${SX_STR_LF}=]*) __sx_arr_is_rw_new_out_="${__sx_arr_is_rw_new_out_} ${__sx_arr_is_rw_new_arg_}";;
          _len[${SX_STR_LF}=]*) __sx_arr_is_rw_new_out_="${__sx_arr_is_rw_new_out_} ${__sx_arr_is_rw_new_arg_}_len";;
          _[0-9]*)
            __sx_arr_is_rw_new_tmp_="${__sx_arr_is_rw_new_rest_%%[${SX_STR_LF}=]*}"

            if sx_str_is_word "${__sx_arr_is_rw_new_tmp_}"; then
              __sx_arr_is_rw_new_tmp_="${__sx_arr_is_rw_new_tmp_#_}"

              if __sx_num_is_nat0_base 10 "${__sx_arr_is_rw_new_tmp_%%_*}"; then
                __sx_arr_is_rw_new_out_="${__sx_arr_is_rw_new_out_} ${__sx_arr_is_rw_new_arg_}_${__sx_arr_is_rw_new_tmp_}"
              fi
            fi
            ;;
        esac

        __sx_arr_is_rw_new_rest_="${__sx_arr_is_rw_new_rest_#*[${SX_STR_LF}=]}"
      done
    done

    eval set -- "${__sx_arr_is_rw_new_out_}"
    unset __sx_arr_is_rw_new_ro_ __sx_arr_is_rw_new_out_ __sx_arr_is_rw_new_arg_ __sx_arr_is_rw_new_rest_ __sx_arr_is_rw_new_tmp_

    __sx_var_is_rw "${@}" || return
  }

  It '正常動作'
    sx_arr_gen arr a b c
    When run efu_run __sx_arr_is_rw_new arr
    The status should be success
  End

  It '読み取り専用要素を検出できること'
    arr_len=1 arr_0=a
    readonly arr_0
    When run efu_run __sx_arr_is_rw_new arr
    The status should be failure
  End
End
