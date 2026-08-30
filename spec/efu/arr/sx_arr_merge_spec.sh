Describe 'sx_arr_merge -efu 環境検証'
  Include ./sx.sh

  Describe '単一の末尾配列へ連結'
    It '引数が0個の場合は成功する'
      When run efu_run sx_arr_merge
      The status should be success
    End

    It '複数の配列を連結する'
      sx_arr_gen a1 a b c
      sx_arr_gen a2 d e

      sx_arr_merge x a1 a2
      The variable "x_len" should equal 5
      The variable "x_0" should equal a
      The variable "x_4" should equal e
    End

    It '源配列が無い場合は空配列を生成する'
      sx_arr_merge x
      The variable "x_len" should equal 0
    End

    It '源配列が空の場合は空配列を生成する'
      sx_arr_gen a1

      sx_arr_merge x a1
      The variable "x_len" should equal 0
    End
  End

  Describe '複数セグメントへの分配'
    It '数値先行セグメントと末尾セグメントへ分配する'
      sx_arr_gen a1 a b c
      sx_arr_gen a2 d e

      sx_arr_merge 2a:x a1 a2
      The variable "a_len" should equal 2
      The variable "a_0" should equal a
      The variable "a_1" should equal b
      The variable "x_len" should equal 3
      The variable "x_0" should equal c
      The variable "x_2" should equal e
    End

    It '素セグメントはスカラーとして扱い配列化しない'
      sx_arr_gen a1 p q r s t

      sx_arr_merge a:2b:x a1
      The variable "a" should equal p
      The variable "b_len" should equal 2
      The variable "x_len" should equal 2
    End
  End

  Describe '切り詰め挙動'
    It '要素が不足する場合は配列長が短くなる（成功）'
      sx_arr_gen a1 p q r

      sx_arr_merge 2a:x a1
      The variable "a_len" should equal 2
      The variable "x_len" should equal 1
    End

    It 'スカラーを挟む未満充填でも配列長が正しいこと'
      sx_arr_gen a1 p

      sx_arr_merge 2a:b:x a1
      The variable "a_len" should equal 1
      The variable "x_len" should equal 0
    End
  End

  Describe '引数バリデーション'
    It 'バインド形式が不正な場合は 64 を返す'
      sx_arr_gen a1 a b
      When run efu_run sx_arr_merge "2b" a1
      The status should equal 64
    End

    It '対象が sx 配列でない場合は 65 を返す'
      notarr=
      When run efu_run sx_arr_merge x notarr
      The status should equal 65
    End
  End
End
