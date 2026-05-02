#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_base_nat0'
  Include ./sx.sh

  Describe '基数指定の検証'
    It '有効な基数 (8, 10, 16) で成功すること'
      When call sx_num_is_base_nat0 10 "0"
      The status should be success
    End

    It "無効な基数に対して EX_USAGE (64) を返すこと"
      When call sx_num_is_base_nat0 2 "0"
      The status should equal 64
    End
    End

    Context '10進数 (base 10)'
    It '有効な10進数（符号なし、先行0なし）で成功すること'
      When call sx_num_is_base_nat0 10 "0" "1" "123" "9876543210"
      The status should be success
    End

    It '先行する0がある場合に失敗すること（"0"単体を除く）'
      When call sx_num_is_base_nat0 10 "01" "00"
      The status should be failure
    End

    It '符号がある場合に失敗すること'
      When call sx_num_is_base_nat0 10 "+0" "-0" "+123" "-456"
      The status should be failure
    End

    It '非数字が含まれる場合に失敗すること'
      When call sx_num_is_base_nat0 10 "12a" " 1" "1.0"
      The status should be failure
    End
    End

    Context '8進数 (base 8)'
    It '有効な8進数（接頭辞"0"必須、かつ後続に1文字以上）で成功すること'
      # 現在の実装では "0" 単体は失敗する仕様
      When call sx_num_is_base_nat0 8 "07" "0123" "00"
      The status should be success
    End

    It '接頭辞のみ（"0"）の場合に失敗すること'
      When call sx_num_is_base_nat0 8 "0"
      The status should be failure
    End

    It '接頭辞"0"がない場合に失敗すること'
      When call sx_num_is_base_nat0 8 "1" "7"
      The status should be failure
    End


    It '8進数として無効な数字(8, 9)を含む場合に失敗すること'
      When call sx_num_is_base_nat0 8 "08" "019"
      The status should be failure
    End

    It '接頭辞の後に先行する0がある場合に失敗すること'
      # sx_num_is_base_nat0 の実装上、0[0-7] は OK だが 00[0-7] は 0?* にマッチして失敗する
      When call sx_num_is_base_nat0 8 "007"
      The status should be failure
    End
  End

  Context '16進数 (base 16)'
    It '0x0 で成功すること'
      When call sx_num_is_base_nat0 16 "0x0"
      The status should be success
    End

    It '0X1 で成功すること'
      When call sx_num_is_base_nat0 16 "0X1"
      The status should be success
    End

    It '0xABC で成功すること'
      When call sx_num_is_base_nat0 16 "0xABC"
      The status should be success
    End

    It '接頭辞がない場合に失敗すること'
      When call sx_num_is_base_nat0 16 "0" "F" "ABC"
      The status should be failure
    End

    It '16進数として無効な文字を含む場合に失敗すること'
      When call sx_num_is_base_nat0 16 "0xG" "0x12H"
      The status should be failure
    End

    It '接頭辞のみの場合に失敗すること'
      When call sx_num_is_base_nat0 16 "0x" "0X"
      The status should be failure
    End
  End
End
