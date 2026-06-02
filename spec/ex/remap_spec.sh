#!/bin/sh

Describe 'sx_ex_remap'
  Include ./sx.sh

  It '終了ステータスを正常にマッピングすること (1:1)'
    When call sx_ex_remap 1:64 ::: sh -c 'exit 1'
    The status should equal 64
  End

  It '複数のマッピングを正しく処理すること'
    When call sx_ex_remap 1:64 2:77 ::: sh -c 'exit 2'
    The status should equal 77
  End

  It '一致するマッピングがない場合は元のステータスを返すこと'
    When call sx_ex_remap 1:64 ::: sh -c 'exit 2'
    The status should equal 2
  End

  It 'デフォルトマッピング (-) を使用して一致しないものをすべて変換すること'
    When call sx_ex_remap 0:0 '-:64' ::: sh -c 'exit 1'
    The status should equal 64
  End

  It 'デフォルトマッピング (-) を使用しても一致するものがあれば優先されること'
    When call sx_ex_remap 0:0 1:77 '-:64' ::: sh -c 'exit 1'
    The status should equal 77
  End

  It 'セパレータ (:::) なしでも自動判別して実行できること'
    When call sx_ex_remap 1:64 true
    The status should be success
  End

  Context 'コロンを含むコマンド名の自動判別'
    setup() {
      touch "./1:1"
      chmod +x "./1:1"
    }
    cleanup() {
      rm -f "./1:1"
    }
    Before 'setup'
    After 'cleanup'

    It '1:1 というファイル名のコマンドを実行できること'
      # 1:1 というファイル名のコマンドを実行。マッピング引数と誤認されないこと。
      When call sx_ex_remap ::: ./1:1
      The status should be success
    End
  End

  It '引数にスペースを含む場合も正しく渡されること'
    func() {
      [ "$1" = "a b" ]
    }
    When call sx_ex_remap 1:64 ::: func "a b"
    The status should be success
  End

  It 'コマンドが指定されていない場合は 0 (SX_EX_OK) を返すこと'
    When call sx_ex_remap 1:64
    The status should equal 0
  End

  Context '名前によるマッピング'
    It '名前を数値にマッピングできること'
      When call sx_ex_remap 1:USAGE ::: sh -c 'exit 1'
      The status should equal 64
    End

    It '数値を名前にマッピングできること'
      When call sx_ex_remap DATAERR:USAGE ::: sh -c 'exit 65'
      The status should equal 64
    End

    It '名前を名前にマッピングできること'
      When call sx_ex_remap DATAERR:SOFTWARE ::: sh -c 'exit 65'
      The status should equal 70
    End

    It '否定 (!) と名前を組み合わせて使用できること'
      When call sx_ex_remap '!OK:USAGE' ::: sh -c 'exit 1'
      The status should equal 64
    End

    It '否定 (!) と名前を組み合わせた場合に一致しなければ元のステータスを返すこと'
      When call sx_ex_remap '!DATAERR:USAGE' ::: sh -c 'exit 65'
      The status should equal 65
    End
  End

  Context '範囲指定マッピング'
    It 'N-M の範囲に一致する場合にマッピングすること'
      When call sx_ex_remap 1-10:64 ::: sh -c 'exit 5'
      The status should equal 64
    End

    It 'N- の範囲（以上）に一致する場合にマッピングすること'
      When call sx_ex_remap 10-:64 ::: sh -c 'exit 15'
      The status should equal 64
    End

    It '-M の範囲（以下）に一致する場合にマッピングすること'
      When call sx_ex_remap -10:64 ::: sh -c 'exit 5'
      The status should equal 64
    End

    It '範囲外の場合は元のステータスを返すこと'
      When call sx_ex_remap 1-10:64 ::: sh -c 'exit 11'
      The status should equal 11
    End
  End
End
