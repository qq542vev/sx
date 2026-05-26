#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_rel'
  Include ./sx.sh

  It '正常な関係（単一の比較）で成功を返すこと'
    When call sx_num_rel 1 '<' 2
    The status should be success
  End

  It '等号（=）で成功を返すこと'
    When call sx_num_rel 10 '=' 10
    The status should be success
  End

  It '不等号（!=）で成功を返すこと'
    When call sx_num_rel 10 '!=' 20
    The status should be success
  End

  It '正常な連鎖比較（昇順）で成功を返すこと'
    When call sx_num_rel 1 '<' 2 '<=' 2 '<' 3
    The status should be success
  End

  It '正常な連鎖比較（混合）で成功を返すこと'
    When call sx_num_rel 10 '>' 5 '=' 5 '<' 10 '!=' 0
    The status should be success
  End

  It '条件を満たさない場合に失敗（1）を返すこと'
    When call sx_num_rel 1 '<' 0
    The status should be failure
  End

  It '連鎖の途中で条件を満たさない場合に失敗（1）を返すこと'
    When call sx_num_rel 1 '<' 2 '<' 1
    The status should be failure
  End

  It '演算子で終わる場合でも成功を返すこと'
    When call sx_num_rel 1 '<'
    The status should be success
  End

  It '無効な演算子が指定された場合に引数不正（64）を返すこと'
    When call sx_num_rel 1 '???' 2
    The status should equal 64
  End

  It '非数値が指定された場合に引数不正（64）を返すこと'
    When call sx_num_rel 1 '<' "abc"
    The status should equal 64
  End

  It '単一の数値のみ（比較なし）の場合に成功を返すこと'
    When call sx_num_rel 1
    The status should be success
  End

  It '空の引数の場合に成功を返すこと'
    When call sx_num_rel
    The status should be success
  End

  Describe '拡張された機能の確認'
    It '演算子から始まる連鎖比較ができること'
      When call sx_num_rel '<' 1 2 3
      The status should be success
    End

    It '動的な演算子の切り替えと連鎖ができること'
      When call sx_num_rel 1 '<' 2 3 4 '=' 4
      The status should be success
    End

    It 'デフォルトで等号比較が行われること'
      When call sx_num_rel 1 2 3
      The status should be failure
    End

    It '演算子を上書きできること'
      When call sx_num_rel '<' '!=' 1 2
      The status should be success
    End

    It '明示的な等号での連鎖ができること'
      When call sx_num_rel 1 '=' 1 1
      The status should be success
    End

    It '数値のみの連鎖で等号比較されること'
      When call sx_num_rel 1 1 1
      The status should be success
    End

    It '異なる演算子での連鎖比較ができること'
      When call sx_num_rel 1 '<' 2 '>' 1
      The status should be success
    End

    It '連鎖の最後で失敗を検出できること'
      When call sx_num_rel 1 '<' 2 '>' 2
      The status should be failure
    End
  End


  Describe '別名演算子の確認'
    It 'eq を正しく処理できること'
      When call sx_num_rel 1 eq 1
      The status should be success
    End
    It 'ne を正しく処理できること'
      When call sx_num_rel 1 ne 2
      The status should be success
    End
    It 'lt を正しく処理できること'
      When call sx_num_rel 1 lt 2
      The status should be success
    End
    It 'le を正しく処理できること'
      When call sx_num_rel 1 le 1
      The status should be success
    End
    It 'gt を正しく処理できること'
      When call sx_num_rel 2 gt 1
      The status should be success
    End
    It 'ge を正しく処理できること'
      When call sx_num_rel 1 ge 1
      The status should be success
    End
  End
End
