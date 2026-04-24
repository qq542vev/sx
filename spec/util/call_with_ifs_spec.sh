Describe 'sx_call_with_ifs'
  Include ./sx.sh
  It '一時的なIFSを使用してコマンドを実行すること'
    func() {
      echo "$#"
    }
    When call sx_call_with_ifs "," func "a,b,c"
    The status should be success
    The stdout should equal "3"
  End

  It '元のIFSを復元すること'
    IFS=":"
    sx_call_with_ifs "," true
    The variable IFS should equal ":"
  End
End
