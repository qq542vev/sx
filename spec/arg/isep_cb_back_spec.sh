# shellcheck shell=sh

Describe 'sx_arg_isep (backward CB mode, int < 0)'
  Include ./sx.sh

  Describe '基本: int=-1（全要素間）'
    It 'int=-1, a b c → a 2 b 1 c'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 "" "$SX_ARG_ISEP_CB" ::: "a" "b" "c"
      The status should be success
      The stdout should equal "12"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "2"
      The value "$3" should equal "b"
      The value "$4" should equal "1"
      The value "$5" should equal "c"
      The value "$#" should equal 5
    End

    It 'cb の呼出順: cb 1 (cの前), cb 2 (bの前)'
      cb() { printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 "" "$SX_ARG_ISEP_CB" ::: "a" "b" "c"
      The status should be success
      The stdout should equal "12"
    End
  End

  Describe '基本: int=-2（2つおき）'
    It 'int=-2, a b c d → a b 1 c d'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -2 "" "$SX_ARG_ISEP_CB" ::: "a" "b" "c" "d"
      The status should be success
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "1"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$#" should equal 5
    End

    It 'int=-2, a b c d e → a 2 b c 1 d e'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -2 "" "$SX_ARG_ISEP_CB" ::: "a" "b" "c" "d" "e"
      The status should be success
      The stdout should equal "12"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "2"
      The value "$3" should equal "b"
      The value "$4" should equal "c"
      The value "$5" should equal "1"
      The value "$6" should equal "d"
      The value "$7" should equal "e"
      The value "$#" should equal 7
    End
  End

  Describe 'PRE フラグ'
    It 'int=-1, PRE, a b → 2 a 1 b'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b"
      The status should be success
      The stdout should equal "12"
      eval "set -- $res"
      The value "$1" should equal "2"
      The value "$2" should equal "a"
      The value "$3" should equal "1"
      The value "$4" should equal "b"
      The value "$#" should equal 4
    End

    It 'int=-2, PRE, a b c d → 2 a b 1 c d'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -2 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b" "c" "d"
      The status should be success
      The stdout should equal "12"
      eval "set -- $res"
      The value "$1" should equal "2"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$4" should equal "1"
      The value "$5" should equal "c"
      The value "$6" should equal "d"
      The value "$#" should equal 6
    End
  End

  Describe 'PRE フラグ (奇数要素数 — PREが挿入されない境界)'
    It 'int=-2, PRE, a b c → PRE無し (r_=-1)'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -2 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b" "c"
      The status should be success
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "1"
      The value "$3" should equal "b"
      The value "$4" should equal "c"
      The value "$#" should equal 4
    End

    It 'int=-2, PRE, a b c d e → PRE無し (r_=-1)'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -2 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b" "c" "d" "e"
      The status should be success
      The stdout should equal "12"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "2"
      The value "$3" should equal "b"
      The value "$4" should equal "c"
      The value "$5" should equal "1"
      The value "$6" should equal "d"
      The value "$7" should equal "e"
      The value "$#" should equal 7
    End

    It 'int=-3, PRE, a b c d → PRE無し (N % 3 ≠ 0)'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -3 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b" "c" "d"
      The status should be success
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "1"
      The value "$3" should equal "b"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$#" should equal 5
    End

    It 'int=-3, PRE, a b c d e → PRE無し (N % 3 ≠ 0)'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -3 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b" "c" "d" "e"
      The status should be success
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "1"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$6" should equal "e"
      The value "$#" should equal 6
    End

    It 'int=-3, PRE, a b c d e f → PRE有り (N % 3 == 0)'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -3 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b" "c" "d" "e" "f"
      The status should be success
      The stdout should equal "12"
      eval "set -- $res"
      The value "$1" should equal "2"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$4" should equal "c"
      The value "$5" should equal "1"
      The value "$6" should equal "d"
      The value "$7" should equal "e"
      The value "$8" should equal "f"
      The value "$#" should equal 8
    End
  End

  Describe 'POST フラグ'
    It 'int=-1, POST, a b → a 2 b 1'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should be success
      The stdout should equal "12"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "2"
      The value "$3" should equal "b"
      The value "$4" should equal "1"
      The value "$#" should equal 4
    End

    It 'int=-2, POST, a b c d → a b 2 c d 1'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -2 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" ::: "a" "b" "c" "d"
      The status should be success
      The stdout should equal "12"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "2"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$6" should equal "1"
      The value "$#" should equal 6
    End
  End

  Describe 'PRE|POST 組み合わせ'
    It 'int=-1, PRE|POST, a b → 3 a 2 b 1'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should be success
      The stdout should equal "123"
      eval "set -- $res"
      The value "$1" should equal "3"
      The value "$2" should equal "a"
      The value "$3" should equal "2"
      The value "$4" should equal "b"
      The value "$5" should equal "1"
      The value "$#" should equal 5
    End

    It 'int=-2, PRE|POST, a b c d → 3 a b 2 c d 1'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -2 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b" "c" "d"
      The status should be success
      The stdout should equal "123"
      eval "set -- $res"
      The value "$1" should equal "3"
      The value "$2" should equal "a"
      The value "$3" should equal "b"
      The value "$4" should equal "2"
      The value "$5" should equal "c"
      The value "$6" should equal "d"
      The value "$7" should equal "1"
      The value "$#" should equal 7
    End
  End

  Describe 'limit 制限'
    It 'int=-1, lim=1, a b c d → a b c 1 d'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 1 "$SX_ARG_ISEP_CB" ::: "a" "b" "c" "d"
      The status should be success
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$4" should equal "1"
      The value "$5" should equal "d"
      The value "$#" should equal 5
    End

    It 'int=-1, lim=0, a b c → 何も挿入されない'
      cb() { __sx_var_set "${1}=x"; }
      When call sx_arg_isep res cb -1 0 "$SX_ARG_ISEP_CB" ::: "a" "b" "c"
      The status should be success
      The stdout should equal ""
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It 'int=-2, lim=1, a b c d → a b 1 c d'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -2 1 "$SX_ARG_ISEP_CB" ::: "a" "b" "c" "d"
      The status should be success
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "1"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$#" should equal 5
    End

    It 'int=-2, lim=2, a b c d → a b 1 c d'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -2 2 "$SX_ARG_ISEP_CB" ::: "a" "b" "c" "d"
      The status should be success
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "1"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$#" should equal 5
    End
  End

  Describe 'limit + PRE/POST'
    It 'int=-1, lim=1, PRE, a b → a 1 b'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 1 \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b"
      The status should be success
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "1"
      The value "$3" should equal "b"
      The value "$#" should equal 3
    End

    It 'int=-1, lim=1, POST, a b → a b 1'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 1 \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should be success
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "1"
      The value "$#" should equal 3
    End

    It 'int=-1, lim=2, PRE|POST, a b → a 2 b 1'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 2 \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should be success
      The stdout should equal "12"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "2"
      The value "$3" should equal "b"
      The value "$4" should equal "1"
      The value "$#" should equal 4
    End
  End

  Describe 'コールバック中断・エラー'
    It 'cb が非0を返すとその回も含めて以後挿入されないこと'
      cb() {
        __sx_var_set "${1}=!"
        printf '%d' "${3}"
        case "$3" in 1) return 1;; esac
      }
      When call sx_arg_isep res cb -1 "" "$SX_ARG_ISEP_CB" ::: "a" "b" "c"
      The status should equal 1
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$#" should equal 3
    End

    It 'cb の終了ステータスがそのまま伝搬されること'
      cb_err() { __sx_var_set "${1}=E"; printf '%d' "${3}"; return 42; }
      When call sx_arg_isep res cb_err -1 "" "$SX_ARG_ISEP_CB" ::: "a" "b"
      The status should equal 42
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$#" should equal 2
    End

    It 'cb が非0を返すとPREもPOSTも挿入されないこと'
      cb_fail_post_first() { __sx_var_set "${1}=X"; printf '%d' "${3}"; return 1; }
      When call sx_arg_isep res cb_fail_post_first -1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should equal 1
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$#" should equal 2
    End

    It '途中のcbが非0を返してもそれ以前のセパレータは挿入されること'
      cb_fail_pre_last() {
        printf '%d' "${3}"
        case "$3" in
          3) __sx_var_set "${1}=!"; return 1;;
          *) __sx_var_set "${1}=($3)";;
        esac
      }
      When call sx_arg_isep res cb_fail_pre_last -1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "a" "b"
      The status should equal 1
      The stdout should equal "123"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "(2)"
      The value "$3" should equal "b"
      The value "$4" should equal "(1)"
      The value "$#" should equal 4
    End

    It '途中のcbが非0を返すとエラーステータスが伝搬され以前の値は挿入されること'
      cb_fail_pre_back() {
        case "$3" in
          2) __sx_var_set "${1}=!"; return 1;;
          *) __sx_var_set "${1}=($3)";;
        esac
      }
      When call sx_arg_isep res cb_fail_pre_back -1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b"
      The status should equal 1
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "(1)"
      The value "$3" should equal "b"
      The value "$#" should equal 3
    End
  End

  Describe '空引数'
    It 'PRE|POST|CB → POST が1つ'
      cb() { __sx_var_set "${1}=X${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 10 \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" :::
      The status should be success
      The stdout should equal "1"
      The variable res should equal "'X1'"
    End

    It 'PRE|CB → 空'
      cb() { __sx_var_set "${1}=X${3}"; }
      When call sx_arg_isep res cb -1 10 \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" :::
      The status should be success
      The stdout should equal ""
      The variable res should equal ""
    End

    It 'POST|CB → POST が1つ'
      cb() { __sx_var_set "${1}=X${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 10 \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" :::
      The status should be success
      The stdout should equal "1"
      The variable res should equal "'X1'"
    End

    It 'CBのみ → 空'
      cb() { __sx_var_set "${1}=X${3}"; }
      When call sx_arg_isep res cb -1 10 "$SX_ARG_ISEP_CB" :::
      The status should be success
      The stdout should equal ""
      The variable res should equal ""
    End
  End

  Describe '特殊文字'
    It "クォートが必要な値が正しく処理されること"
      cb() { __sx_var_set "${1}=[@$3]"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 "" "$SX_ARG_ISEP_CB" ::: "hello world" "foo'bar"
      The status should be success
      The stdout should equal "1"
      eval "set -- $res"
      The value "$1" should equal "hello world"
      The value "$2" should equal "[@1]"
      The value "$3" should equal "foo'bar"
      The value "$#" should equal 3
    End
  End

  Describe '分配代入 (bind)'
    It '単一変数に代入できること'
      cb() { __sx_var_set "${1}=SEP"; }
      sx_arg_isep res cb -1 "" "$SX_ARG_ISEP_CB" ::: "a" "b"
      The variable res should equal "'a' 'SEP' 'b'"
    End

    It 'スキップを含む分配代入: ::v3'
      cb() { __sx_var_set "${1}=SEP"; }
      sx_arg_isep "::v3" cb -1 "" "$SX_ARG_ISEP_CB" ::: "a" "b"
      The variable v1 should be undefined
      The variable v2 should be undefined
      The variable v3 should equal "'b'"
    End
  End

  Describe '1要素'
    It '要素が1つ = セパレータなし'
      cb() { __sx_var_set "${1}=x"; }
      When call sx_arg_isep res cb -1 "" "$SX_ARG_ISEP_CB" ::: "only"
      The status should be success
      The stdout should equal ""
      The variable res should equal "'only'"
    End

    It '1要素 + PRE|POST → PRE と POST'
      cb() { __sx_var_set "${1}=($3)"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE | SX_ARG_ISEP_POST))" ::: "x"
      The status should be success
      The stdout should equal "12"
      eval "set -- $res"
      The value "$1" should equal "(2)"
      The value "$2" should equal "x"
      The value "$3" should equal "(1)"
      The value "$#" should equal 3
    End

    It '1要素 + PRE (int=-1) → PRE が挿入されること'
      cb() { __sx_var_set "${1}=P$3"; }
      When call sx_arg_isep res cb -1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "x"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "P1"
      The value "$2" should equal "x"
      The value "$#" should equal 2
    End

    It '1要素 + PRE (int=-2) → PRE が挿入されないこと (r_=-1)'
      cb() { __sx_var_set "${1}=P$3"; }
      When call sx_arg_isep res cb -2 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "x"
      The status should be success
      The variable res should equal "'x'"
    End

    It '1要素 + POST (int=-1) → POST が挿入されること'
      cb() { __sx_var_set "${1}=P$3"; }
      When call sx_arg_isep res cb -1 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" ::: "x"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "x"
      The value "$2" should equal "P1"
      The value "$#" should equal 2
    End

    It '1要素 + POST (int=-2) → POST が挿入されること'
      cb() { __sx_var_set "${1}=P$3"; }
      When call sx_arg_isep res cb -2 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" ::: "x"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "x"
      The value "$2" should equal "P1"
      The value "$#" should equal 2
    End
  End

  Describe '大きなインターバル (|int| > 要素数)'
    It 'int=-10, PRE, a b c → セパレータ無し'
      cb() { __sx_var_set "${1}=P$3"; }
      When call sx_arg_isep res cb -10 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_PRE))" ::: "a" "b" "c"
      The status should be success
      The variable res should equal "'a' 'b' 'c'"
    End

    It 'int=-10, POST, a b c → POST のみ'
      cb() { __sx_var_set "${1}=P$3"; }
      When call sx_arg_isep res cb -10 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" ::: "a" "b" "c"
      The status should be success
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "c"
      The value "$4" should equal "P1"
      The value "$#" should equal 4
    End

    It 'int=-10, POST, 空引数 → POST のみ'
      cb() { __sx_var_set "${1}=P$3"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -10 "" \
        "$((SX_ARG_ISEP_CB | SX_ARG_ISEP_POST))" :::
      The status should be success
      The stdout should equal "1"
      The variable res should equal "'P1'"
    End
  End

  Describe '回帰テスト: 内部セパレータのオーバーコンシューム防止'
    It 'int=-2, 6要素 → cnt_=2に対し発火3回にならないこと'
      cb() { __sx_var_set "${1}=${3}"; printf '%d' "${3}"; }
      When call sx_arg_isep res cb -2 "" "$SX_ARG_ISEP_CB" ::: "a" "b" "c" "d" "e" "f"
      The status should be success
      The stdout should equal "12"
      eval "set -- $res"
      The value "$1" should equal "a"
      The value "$2" should equal "b"
      The value "$3" should equal "2"
      The value "$4" should equal "c"
      The value "$5" should equal "d"
      The value "$6" should equal "1"
      The value "$7" should equal "e"
      The value "$8" should equal "f"
      The value "$#" should equal 8
    End
  End

  Describe '読み取り専用変数エラー'
    It '読み取り専用変数に書こうとすると EX_NOPERM'
      cb() { __sx_var_set "${1}=x"; }
      readonly ro_var_cb_back="fixed"
      When call sx_arg_isep ro_var_cb_back cb -1 "" "$SX_ARG_ISEP_CB" ::: "a"
      The status should equal 77
    End
  End
End
