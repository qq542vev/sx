Describe 'sx_arr_get -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    sx_arr_gen myarr a b c d e

    When run efu_run sx_arr_get x myarr 3:0:-1
    The status should be success
  End

  It '範囲取得ができること (t<0 は終端を含む)'
    sx_arr_gen myarr a b c d e

    sx_arr_get x myarr 3:0:-1
    The variable "x_len" should equal 4
    The variable "x_0" should equal d
    The variable "x_2" should equal b
    The variable "x_3" should equal a
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

  Context '算術域境界 (NUM_RANGE=64)'
    arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64

    It 't<0 クランプの中間値が溢れないこと (始点D・step-5・境界)'
      sx_cfg_set NUM_RANGE=64
      sx_arr_gen myarr a b c d e
      When call sx_arr_get x myarr 9223372036854775807:0:-5
      The status should be success
      The variable "x_len" should equal 1
      The variable "x_0" should equal c
    End

    It 't<0 クランプの中間値が溢れないこと (始点D・step-6)'
      sx_cfg_set NUM_RANGE=64
      sx_arr_gen myarr a b c d e
      When call sx_arr_get x myarr 9223372036854775807:0:-6
      The status should be success
      The variable "x_len" should equal 1
      The variable "x_0" should equal b
    End

    It 't<0 クランプ境界 (|t|=4) は溢れずに解決すること'
      sx_cfg_set NUM_RANGE=64
      sx_arr_gen myarr a b c d e
      When call sx_arr_get x myarr 9223372036854775807:0:-4
      The status should be success
      The variable "x_len" should equal 1
      The variable "x_0" should equal d
    End

    It '開始値が算術最小値でも正規化が溢れず全件を解決すること'
      sx_cfg_set NUM_RANGE=64
      sx_arr_gen myarr a b c d e
      When call sx_arr_get x myarr -9223372036854775813:10:1
      The status should be success
      The variable "x_len" should equal 5
      The variable "x_0" should equal a
      The variable "x_4" should equal e
    End

    It '負始点と巨大正stepの正規化が溢れず空で終えること'
      sx_cfg_set NUM_RANGE=64
      sx_arr_gen myarr a b c d e
      When call sx_arr_get x myarr -9000000000000000000:10:9000000000000000000
      The status should be success
      The variable "x_len" should equal 0
    End
  End
End
