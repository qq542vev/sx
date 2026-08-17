# shellcheck shell=sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_enough'
  Include ./sx.sh

  Describe '全要素成功'
    It 'count <= 要素数の場合に成功する'
      cb() { return 0; }
      When call sx_arg_enough cb 2 ::: a b c
      The status should be success
    End

    It 'count == 要素数の場合に成功する'
      cb() { return 0; }
      When call sx_arg_enough cb 3 ::: a b c
      The status should be success
    End

    It 'count > 要素数の場合に失敗する'
      cb() { return 0; }
      When call sx_arg_enough cb 4 ::: a b c
      The status should equal 1
    End
  End

  Describe '条件フィルタリング'
    It '奇数が2つ以上ある'
      is_odd() { case $(($1 % 2)) in 1) return 0;; *) return 1;; esac; }
      When call sx_arg_enough is_odd 2 ::: 1 2 3 4
      The status should be success
    End

    It '奇数が3つ以上はない'
      is_odd() { case $(($1 % 2)) in 1) return 0;; *) return 1;; esac; }
      When call sx_arg_enough is_odd 3 ::: 1 2 3 4
      The status should equal 1
    End

    It '全要素失敗'
      is_even() { case $(($1 % 2)) in 0) return 0;; *) return 1;; esac; }
      When call sx_arg_enough is_even 1 ::: 1 3 5
      The status should equal 1
    End
  End

  Describe 'count=0'
    It '常に成功し、callback は呼ばれない'
      cb() { return 1; }
      When call sx_arg_enough cb 0 ::: a b c
      The status should be success
    End
  End

  Describe '空リスト'
    It 'count > 0 なら失敗'
      cb() { return 0; }
      When call sx_arg_enough cb 1 :::
      The status should equal 1
    End

    It 'count=0 なら成功'
      cb() { return 1; }
      When call sx_arg_enough cb 0 :::
      The status should be success
    End
  End

  Describe '短絡評価 (positive)'
    It '必要数に達した時点で早期成功'
      call_count=0
      cb() { : $((call_count += 1)); return 0; }
      When call sx_arg_enough cb 2 ::: a b c d
      The status should be success
      The variable call_count should equal 2
    End
  End

  Describe '短絡評価 (negative)'
    It '残りが不足した時点で早期失敗'
      call_count=0
      is_odd() { : $((call_count += 1)); case $(($1 % 2)) in 1) return 0;; *) return 1;; esac; }
      When call sx_arg_enough is_odd 3 ::: 1 2 3
      The status should equal 1
      The variable call_count should equal 2
    End
  End

  Describe '再帰呼び出し'
    It '状態が壊れない'
      inner_cb() { case $(($1 % 2)) in 1) return 0;; esac; return 1; }
      outer_cb() {
        case "${1}" in
          a) sx_arg_enough inner_cb 2 ::: 1 3 5 && return 0 || return 1;;
          *) return 1;;
        esac
      }
      When call sx_arg_enough outer_cb 1 ::: a b c
      The status should be success
    End
  End

  Describe '高速モード'
    It 'SX_CFG_SKIP_CHK=1 で正しく動作する'
      cb() { return 0; }
      SX_CFG_SKIP_CHK=1
      When call sx_arg_enough cb 2 ::: a b c
      The status should be success
    End
  End

  Describe 'need の省略'
    It 'need を省略すると全要素数で代用される'
      cb() { return 0; }
      When call sx_arg_enough cb ::: a b c
      The status should be success
    End

    It 'need を省略し空リストなら成功する'
      cb() { return 0; }
      When call sx_arg_enough cb :::
      The status should be success
    End
  End

  Describe 'cb の省略'
    It 'cb を省略すると空文字列になり常に失敗する'
      When call sx_arg_enough ::: a b c
      The status should equal 1
      The stderr should not be blank
    End

    It 'cb 省略 + 空リストは need=0 となり成功する'
      When call sx_arg_enough :::
      The status should be success
    End
  End

  Describe 'エラーケース'
    It 'count が負数の場合に EX_USAGE を返す'
      cb() { return 0; }
      When call sx_arg_enough cb -1 ::: a b
      The status should equal 64
    End
  End

  Describe '内部関数 (__sx_arg_enough)'
    It '__sx_arg_enough が正しく動作する'
      cb() { return 0; }
      When call __sx_arg_enough cb 2 ::: a b c
      The status should be success
    End
  End
End
