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

  It '引数の個数が偶数の場合（演算子で終わるなど）に引数不正（64）を返すこと'
    When call sx_num_rel 1 '<'
    The status should equal 64
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

  It '空の引数の場合に引数不正（64）を返すこと（本来は奇数個だが0は特殊扱い）'
    # 現在の実装では 0 % 2 = 0 なので引数不正(64)になる
    When call sx_num_rel
    The status should equal 64
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
