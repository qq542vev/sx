#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_ex_yield'
  Include ./sx.sh

  Describe '終了ステータスを返すこと'
    It 'デフォルトで 0 を返すこと'
      When call sx_ex_yield
      The status should be success
      The status should equal 0
    End

    It '明示的に 0 を返すこと'
      When call sx_ex_yield 0
      The status should be success
      The status should equal 0
    End

    It '1 を返すこと'
      When call sx_ex_yield 1
      The status should be failure
      The status should equal 1
    End

    It '255 を返すこと'
      When call sx_ex_yield 255
      The status should be failure
      The status should equal 255
    End

    It 'SX_EX_USAGE (64) を返すこと'
      When call sx_ex_yield 64
      The status should equal 64
    End

    It '名前でステータスを返すこと (DATAERR -> 65)'
      When call sx_ex_yield DATAERR
      The status should equal 65
    End

    It '名前でステータスを返すこと (USAGE -> 64)'
      When call sx_ex_yield USAGE
      The status should equal 64
    End

    It '名前でステータスを返すこと (NOPERM -> 77)'
      When call sx_ex_yield NOPERM
      The status should equal 77
    End

    It '名前でステータスを返すこと (CONFIG -> 78)'
      When call sx_ex_yield CONFIG
      The status should equal 78
    End

    It '名前でステータスを返すこと (OK -> 0)'
      When call sx_ex_yield OK
      The status should be success
    End
  End

  Describe '無効なステータス'
    It '256 に対して SX_EX_USAGE (64) を返すこと'
      When call sx_ex_yield 256
      The status should equal 64
    End

    It '-1 に対して SX_EX_USAGE (64) を返すこと'
      When call sx_ex_yield -1
      The status should equal 64
    End

    It '非数値に対して SX_EX_USAGE (64) を返すこと'
      When call sx_ex_yield abc
      The status should equal 64
    End

    It '未知の名前に対して SX_EX_USAGE (64) を返すこと'
      When call sx_ex_yield UNKNOWN
      The status should equal 64
    End

    It '小文字の名前に対して SX_EX_USAGE (64) を返すこと'
      When call sx_ex_yield dataerr
      The status should equal 64
    End
  End

  Describe 'SX_CFG_SKIP_CHK=1 の場合'
    It 'バリデーションなしで 123 を返すこと'
      SX_CFG_SKIP_CHK=1
      When call sx_ex_yield 123
      The status should equal 123
    End

    It 'バリデーションなしでデフォルトの 0 を返すこと'
      SX_CFG_SKIP_CHK=1
      When call sx_ex_yield
      The status should equal 0
    End
  End
End
