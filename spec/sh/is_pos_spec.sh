#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_sh_is_pos'
  sxtest_load ./build/modules/SX_SH_REJECT_POS.sh ./build/modules/SX_SH_ACCEPT_POS.sh ./build/modules/sx_sh_is_pos.sh

  It '位置パラメータに対して成功を返すこと'
    When call sx_sh_is_pos 1 09 57 000006
    The status should be success
  End

  It '引数がない場合に成功を返すこと'
    When call sx_sh_is_pos
    The status should be success
  End

  It '0 に対して失敗を返すこと'
    When call sx_sh_is_pos 0
    The status should be failure
  End

  It '全て 0 の位置パラメータに対して失敗を返すこと'
    When call sx_sh_is_pos 00 000 000000
    The status should be failure
  End

  It '数字とそれ以外が混在する文字列に対して失敗を返すこと'
    When call sx_sh_is_pos 1a a1 01a 0a 0x1
    The status should be failure
  End

  It '数字以外の文字列に対して失敗を返すこと'
    When call sx_sh_is_pos a _ aaa -1 +1 '@' '*'
    The status should be failure
  End

  It '空文字列に対して失敗を返すこと'
    When call sx_sh_is_pos ""
    The status should be failure
  End

  It '有効と無効が混在する場合に失敗を返すこと'
    When call sx_sh_is_pos 1 00
    The status should be failure
  End

  Describe 'SX_SH_REJECT_POS / SX_SH_ACCEPT_POS'
    is_pos_eval() {
      eval "case \"\$1\" in $SX_SH_REJECT_POS) return 1;; esac"
      eval "case \"\$1\" in $SX_SH_ACCEPT_POS) return 0;; esac"
      return 1
    }

    rejects_only() {
      eval "case \"\$1\" in $SX_SH_REJECT_POS) return 0;; esac"
      return 1
    }

    It '定数だけで位置パラメータを受け付けること'
      When call is_pos_eval 000006
      The status should be success
    End

    It '定数だけで全て 0 の位置パラメータを拒否すること'
      When call is_pos_eval 00
      The status should be failure
    End

    It '定数だけで数字以外を含む文字列を拒否すること'
      When call is_pos_eval a1
      The status should be failure
    End

    It 'REJECT 単独では 00 に一致しないこと'
      When call rejects_only 00
      The status should be failure
    End
  End
End
