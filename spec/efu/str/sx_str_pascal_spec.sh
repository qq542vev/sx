Describe 'sx_str_pascal -efu 環境検証'
  Include ./spec/support/prepare.sh
  Include ./spec/support/library.sh sx_str_pascal

  It '正常動作'
    When run efu_run sx_str_pascal res "hello_world"
    The status should be success
  End

  Parameters
    0
    1
  End

  It '多倍長経路を -efu 下で検査省略の有無によらず処理できること'
    __sx_num_is_int_fit_dec() {
      case "${#}:${2-}" in
        2:9 | 2:10 | 2:11 | 2:12 | 5:9 | 5:10 | 5:11 | 5:12) return 1;;
      esac
      return 0
    }
    __sx_num_add1_arith() { return 64; }
    sx_test_setup sx_cfg_set "SKIP_CHK=$1"
    When run efu_run sx_str_pascal res XMLParser
    The status should be success
  End
End
