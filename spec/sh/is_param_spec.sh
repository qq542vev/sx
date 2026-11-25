#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_sh_is_param'
  sxtest_load ./build/modules/SX_SH_REJECT_PARAM.sh ./build/modules/SX_SH_ACCEPT_PARAM.sh ./build/modules/sx_sh_is_param.sh

  It '特殊パラメータに対して成功を返すこと'
    When call sx_sh_is_param @ '*' '#' '?' '-' '$' '!'
    The status should be success
  End

  It '0 に対して成功を返すこと'
    When call sx_sh_is_param 0
    The status should be success
  End

  It '位置パラメータに対して成功を返すこと'
    When call sx_sh_is_param 5 10 008 0008 010 0000008
    The status should be success
  End

  It '変数名に対して成功を返すこと'
    When call sx_sh_is_param aaa _ _x a1 VAR_123 1 9 _1 a0
    The status should be success
  End

  It '引数がない場合に成功を返すこと'
    When call sx_sh_is_param
    The status should be success
  End

  It '全て 0 の位置パラメータに対して失敗を返すこと'
    When call sx_sh_is_param 00 000
    The status should be failure
  End

  It '記号を含む文字列に対して失敗を返すこと'
    When call sx_sh_is_param '&' 'a-b' 'a.b'
    The status should be failure
  End

  It '数字で始まり数字以外を含む文字列に対して失敗を返すこと'
    When call sx_sh_is_param 1ggg 12a 1_ 9a 0x1 01a 0a
    The status should be failure
  End

  It '非WORDで始まる複数文字の文字列に対して失敗を返すこと'
    When call sx_sh_is_param -1 +1 '$1'
    The status should be failure
  End

  It '空文字列に対して失敗を返すこと'
    When call sx_sh_is_param ""
    The status should be failure
  End

  It '有効と無効が混在する場合に失敗を返すこと'
    When call sx_sh_is_param aaa '&'
    The status should be failure
  End

  Describe 'SX_SH_REJECT_PARAM / SX_SH_ACCEPT_PARAM'
    is_param_eval() {
      eval "case \"\$1\" in $SX_SH_REJECT_PARAM) return 1;; esac"
      eval "case \"\$1\" in $SX_SH_ACCEPT_PARAM) return 0;; esac"
      return 1
    }

    rejects_only() {
      eval "case \"\$1\" in $SX_SH_REJECT_PARAM) return 0;; esac"
      return 1
    }

    It '定数だけで有効なパラメータを受け付けること'
      When call is_param_eval aaa
      The status should be success
    End

    It '定数だけで特殊パラメータを受け付けること'
      When call is_param_eval '@'
      The status should be success
    End

    It '定数だけで先頭 0 付きの位置パラメータを受け付けること'
      When call is_param_eval 0008
      The status should be success
    End

    It '定数だけで全て 0 の位置パラメータを拒否すること'
      When call is_param_eval 00
      The status should be failure
    End

    It '定数だけで記号を含む文字列を拒否すること'
      When call is_param_eval 'a-b'
      The status should be failure
    End

    It 'REJECT 単独では & に一致しないこと'
      When call rejects_only '&'
      The status should be failure
    End
  End
End
