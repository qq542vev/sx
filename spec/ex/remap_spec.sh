#!/bin/sh

Describe 'sx_ex_remap'
  Include ./sx.sh

  It '終了ステータスを正常にマッピングすること (1:1)'
    When call sx_ex_remap 1:64 -- sh -c 'exit 1'
    The status should equal 64
  End

  It '複数のマッピングを正しく処理すること'
    When call sx_ex_remap 1:64 2:77 -- sh -c 'exit 2'
    The status should equal 77
  End

  It '一致するマッピングがない場合は元のステータスを返すこと'
    When call sx_ex_remap 1:64 -- sh -c 'exit 2'
    The status should equal 2
  End

  It 'ワイルドカード (*) を使用して一致しないものをすべて変換すること'
    When call sx_ex_remap 0:0 '*:64' -- sh -c 'exit 1'
    The status should equal 64
  End

  It 'ワイルドカード (*) を使用しても一致するものがあれば優先されること'
    When call sx_ex_remap 0:0 1:77 '*:64' -- sh -c 'exit 1'
    The status should equal 77
  End

  It 'セパレータ (--) なしでも自動判別して実行できること'
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
      When call sx_ex_remap -- ./1:1
      The status should be success
    End
  End

  It '引数にスペースを含む場合も正しく渡されること'
    func() {
      [ "$1" = "a b" ]
    }
    When call sx_ex_remap 1:64 -- func "a b"
    The status should be success
  End

  It 'コマンドが指定されていない場合は SX_EX_USAGE を返すこと'
    When call sx_ex_remap 1:64
    The status should equal 64
  End
End
