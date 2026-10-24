# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
Describe 'sx_str_title -efu 環境検証'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_str_title.sh

  It '正常動作'
    When run efu_run sx_str_title res "aaa bbb ccc"
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
    sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
    When run efu_run sx_str_title res XMLParser
    The status should be success
  End
End
