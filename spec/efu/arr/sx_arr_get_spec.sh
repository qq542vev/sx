Describe 'sx_arr_get -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    sx_arr_gen myarr a b c d e

    When run efu_run sx_arr_get x myarr 3:0:-1
    The status should be success
  End

  It '範囲取得ができること'
    sx_arr_gen myarr a b c d e

    sx_arr_get x myarr 3:0:-1
    The variable "x_len" should equal 3
    The variable "x_0" should equal d
    The variable "x_2" should equal b
  End

  It '逆方向の2要素範囲は既定stepでは空であること'
    sx_arr_gen myarr a b c d e

    sx_arr_get x myarr 3:0
    The variable "x_len" should equal 0
  End

  It '終端省略の降順ができること'
    sx_arr_gen myarr a b c d e

    sx_arr_get x myarr 2::-1
    The variable "x_len" should equal 3
    The variable "x_0" should equal c
    The variable "x_2" should equal a
  End
End
