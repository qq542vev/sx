#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '__sx_arr_is_rw_new'
  Include ./sx.sh

  # テスト対象関数は sx.sh に未収録（sx.m4 にのみ存在）のため、
  # ここでは m4 展開後の生成コードを直接定義して検証する。
  # 本体に組み込まれた後は、この定義部分は不要になる。
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

  It '配列要素が読み取り専用でない場合は成功を返すこと'
    sx_arr_gen myarr a b c
    When call __sx_arr_is_rw_new myarr
    The status should be success
  End

  It '要素が読み取り専用の場合に失敗を返すこと'
    arr_len=2 arr_0=a arr_1=b
    readonly arr_0
    When call __sx_arr_is_rw_new arr
    The status should be failure
  End

  It '長さ変数が読み取り専用の場合に失敗を返すこと'
    arr_len=2 arr_0=a arr_1=b
    readonly arr_len
    When call __sx_arr_is_rw_new arr
    The status should be failure
  End

  It '配列名（シグネチャ変数）が読み取り専用の場合に失敗を返すこと'
    sx_arr_gen sig_arr a
    readonly sig_arr
    When call __sx_arr_is_rw_new sig_arr
    The status should be failure
  End

  It '多桁インデックスの要素が読み取り専用の場合に失敗を返すこと'
    arr_len=100
    arr_0=a
    arr_49=mid
    readonly arr_49
    When call __sx_arr_is_rw_new arr
    The status should be failure
  End

  It '複数の要素が読み取り専用の場合に失敗を返すこと'
    arr_len=3 arr_0=a arr_1=b arr_2=c
    readonly arr_0 arr_2
    When call __sx_arr_is_rw_new arr
    The status should be failure
  End

  It 'インデックスでない末尾のスカラ（_foo 等）は要素として誤検知しないこと'
    arr_len=1 arr_0=a
    arr_foo=scalar
    readonly arr_foo
    When call __sx_arr_is_rw_new arr
    The status should be success
  End

  It '別変数が配列名の前方一致でも誤検知しないこと（rlen と rl）'
    rl_len=1 rl_0=a
    rlen=9
    readonly rlen
    When call __sx_arr_is_rw_new rl
    The status should be success
  End

  It '値に改行を含む読み取り専用要素を検出できること'
    newline_arr_len=2
    newline_arr_0="line1
line2"
    readonly newline_arr_0
    When call __sx_arr_is_rw_new newline_arr
    The status should be failure
  End

  It '空値を保持する読み取り専用要素を検出できること'
    arr_len=1
    arr_0=""
    readonly arr_0
    When call __sx_arr_is_rw_new arr
    The status should be failure
  End

  It '複数の配列名を指定して判定できること'
    sx_arr_gen first a
    sx_arr_gen second b
    readonly second_0
    When call __sx_arr_is_rw_new first second
    The status should be failure
  End
End
