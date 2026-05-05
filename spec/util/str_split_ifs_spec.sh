#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_split_ifs'
  Include ./sx.sh

  Describe 'POSIX Word Splitting 準拠のテスト'
    
    It '引数が空文字列の場合、要素は0個となる'
      split_test() {
        IFS=',' sx_str_split_ifs res ""
      }
      When call split_test
      The variable res should equal ""
    End

    It '非空白文字1つの場合、空の要素1つとなる'
      split_test() {
        IFS=',' sx_str_split_ifs res ","
      }
      When call split_test
      The variable res should equal "''"
    End

    It '末尾の非空白区切り文字は無視される (a, -> a)'
      split_test() {
        IFS=',' sx_str_split_ifs res "a,"
      }
      When call split_test
      The variable res should equal "'a'"
    End

    It '先頭の非空白区切り文字は空要素を生成する (,a -> "" a)'
      split_test() {
        IFS=',' sx_str_split_ifs res ",a"
      }
      When call split_test
      The variable res should equal "'' 'a'"
    End

    It '複数の非空白区切り文字が混在する場合 (IFS=",=")'
      split_test() {
        IFS=',=' sx_str_split_ifs res "a,b,c e=f=g"
      }
      When call split_test
      # スペースはIFSに含まれていないので "c e" は1つの単語
      The variable res should equal "'a' 'b' 'c e' 'f' 'g'"
    End

    It '空白文字IFSの場合、先頭・末尾の空白は無視され、連続する空白は1つとみなされる'
      split_test() {
        IFS=' ' sx_str_split_ifs res "  a  b   c  "
      }
      When call split_test
      The variable res should equal "'a' 'b' 'c'"
    End

    It '空白文字のみの場合、要素は0個となる'
      split_test() {
        IFS=' ' sx_str_split_ifs res "   "
      }
      When call split_test
      The variable res should equal ""
    End

    It '空白と非空白が混在するIFSの場合'
      split_test() {
        IFS=', ' sx_str_split_ifs res " a , b  ,  c "
      }
      When call split_test
      # 空白は非空白区切り文字の前後で無視される
      The variable res should equal "'a' 'b' 'c'"
    End

    It '非空白文字が連続する場合、空要素が生成される'
      split_test() {
        IFS=',' sx_str_split_ifs res "a,,c"
      }
      When call split_test
      The variable res should equal "'a' '' 'c'"
    End
  End
End
