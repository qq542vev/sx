#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_sub 多倍長対応'
  Include ./sx.sh

  cb_replace() { __sx_var_set "${1}=X"; }

  Context '巨大な正負の回数制限'
    Parameters
      2147483648 a 0
      -2147483648 a 0
      9223372036854775807 a 0
      -9223372036854775808 a 0
      999999999999999999999999999999 a 0
      -999999999999999999999999999999 a 0
      2147483648 '[a]' 1
      -2147483648 '[a]' 1
      -9223372036854775808 '[a]' 1
      999999999999999999999999999999 '[a]' 1
      -999999999999999999999999999999 '[a]' 1
      2147483648 a 2
      -2147483648 a 2
      -9223372036854775808 a 2
      999999999999999999999999999999 a 2
      -999999999999999999999999999999 a 2
      2147483648 '[a]' 3
      -2147483648 '[a]' 3
      -9223372036854775808 '[a]' 3
      999999999999999999999999999999 '[a]' 3
      -999999999999999999999999999999 '[a]' 3
    End

    It '元文字列内の全マッチを置換できること'
      case "$3" in 0 | 1) rep=X;; *) rep=cb_replace;; esac
      When call sx_str_sub res:cnt aba "$2" "$rep" "$1" "$3"
      The status should be success
      The variable res should equal XbX
      The variable cnt should equal "'2'"
    End
  End

  Context '空パターンおよび * のみの Glob'
    Parameters
      '' '' 0
      '' '' 2
      '' '*' 1
      '' '**' 3
      999999999999999999999999999999 '' 0
      -999999999999999999999999999999 '' 0
      -9223372036854775808 '' 2
      999999999999999999999999999999 '**' 1
      -999999999999999999999999999999 '*' 3
      +2 '' 0
      -2 '' 2
    End

    It 'isep に上限と方向を渡すこと'
      case "$3" in 0 | 1) rep=X;; *) rep=cb_replace;; esac
      case "$1" in +2) expected=XaXb count=2;; -2) expected=aXbX count=2;; *) expected=XaXbX count=3;; esac
      When call sx_str_sub res:cnt ab "$2" "$rep" "$1" "$3"
      The status should be success
      The variable res should equal "$expected"
      The variable cnt should equal "'$count'"
    End
  End

  Context '回数制限0'
    Parameters
      0 a 0
      +0 a 1
      -0 a 2
      0 '[a]' 3
      +0 '' 0
      -0 '' 2
      0 '*' 1
      -0 '**' 3
    End

    It 'パターン生成もコールバック呼び出しも行わないこと'
      __sx_str_qm() { return 64; }
      cb_stop() { return 77; }
      When call sx_str_sub res:cnt aba "$2" cb_stop "$1" "$3"
      The status should be success
      The variable res should equal aba
      The variable cnt should equal "'0'"
    End
  End

  Context '不正な回数制限'
    Parameters
      01
      +01
      -01
      010
      0x10
      -0x10
      +
      -
      abc
      1+1
    End

    It '結果を変更せず64を返すこと'
      res=original cnt=original
      When call sx_str_sub res:cnt aba a X "$1"
      The status should equal 64
      The variable res should equal original
      The variable cnt should equal original
    End
  End

  Context '短い文字列で多倍長経路を強制'
    Parameters
      +2 a 0 XbXba 2
      -2 a 0 abXbX 2
      '' '[a]' 1 XbXbX 3
      -999999999999999999999999999999 '[a]' 1 XbXbX 3
      2 a 2 XbXba 2
      -2 a 2 abXbX 2
      '' '[a]' 3 XbXbX 3
      -999999999999999999999999999999 '[a]' 3 XbXbX 3
    End

    It '有限上限と省略上限を守ること'
      __sx_num_is_int_fit_dec() {
        case "${#}:${2-}" in 2:5 | 2:6 | 3:5 | 3:6) return 1;; esac
        return 0
      }
      __sx_num_add1_arith() { return 64; }
      case "$3" in 0 | 1) rep=X;; *) rep=cb_replace;; esac
      When call sx_str_sub res:cnt ababa "$2" "$rep" "$1" "$3"
      The status should be success
      The variable res should equal "$4"
      The variable cnt should equal "'$5'"
    End
  End

  Context '8bit範囲の最大文字列長の前後'
    Parameters
      126 a 0
      127 a 0
      128 a 0
      128 '[a]' 1
      126 a 2
      127 a 2
      128 a 2
      128 '[a]' 3
    End

    It '元文字列長までカウンタを増やせること'
      sx_str_rep str a "$1"
      sx_str_rep expected X "$1"
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      __sx_cfg_set NUM_RANGE=8
      case "$1" in
        128) __sx_num_add1_arith() { return 64; };;
        *) __sx_num_add1_nat0() { return 64; };;
      esac
      case "$3" in 0 | 1) rep=X;; *) rep=cb_replace;; esac
      When call __sx_str_sub res:cnt "$str" "$2" "$rep" '' "$3"
      The status should be success
      The variable res should equal "$expected"
      The variable cnt should equal "'$1'"
    End
  End

  Context '空パターンで8bit範囲の最大文字列長+1回置換'
    Parameters
      '' '' 0
      -999999999999999999999999999999 '*' 1
      '' '' 2
      -9223372036854775808 '**' 3
    End

    It '両端を含む128回を多倍長経路で数えること'
      sx_str_rep str a 127
      sx_str_rep expected aX 127
      expected="X${expected}"
      __sx_cfg_set NUM_RANGE=8
      __sx_num_add1_arith() { return 64; }
      case "$3" in 0 | 1) rep=X;; *) rep=cb_replace;; esac
      When call __sx_str_sub res:cnt "$str" "$2" "$rep" "$1" "$3"
      The status should be success
      The variable res should equal "$expected"
      The variable cnt should equal "'128'"
    End
  End

  Context '多倍長経路でのコールバック中断'
    Parameters
      999999999999999999999999999999 a 2 1 abaaba 0
      999999999999999999999999999999 a 2 2 Xbaaba 1
      -999999999999999999999999999999 a 2 1 abaaba 0
      -999999999999999999999999999999 a 2 2 abaabX 1
      999999999999999999999999999999 '[a]' 3 2 Xbaaba 1
      -999999999999999999999999999999 '[a]' 3 2 abaabX 1
      999999999999999999999999999999 '' 2 2 Xabaaba 1
      -999999999999999999999999999999 '*' 3 2 abaabaX 1
    End

    It '失敗した回を数えず未処理の元文字列と終了状態を保持すること'
      __sx_num_is_int_fit_dec() {
        case "${#}:${2-}" in 2:5 | 2:6 | 3:5 | 3:6) return 1;; esac
        return 0
      }
      __sx_num_add1_arith() { return 64; }
      stop_at=$4
      cb_stop() {
        __sx_var_set "${1}=X"
        case "${5}" in "$stop_at") return 77;; esac
      }
      When call sx_str_sub res:cnt abaaba "$2" cb_stop "$1" "$3"
      The status should equal 77
      The variable res should equal "$5"
      The variable cnt should equal "'$6'"
    End
  End

  Context '多倍長経路での再入呼び出し'
    Parameters
      999999999999999999999999999999 a 2 '[1]b[2]b[3]' 3
      -999999999999999999999999999999 '[a]' 3 '[3]b[2]b[1]' 3
      999999999999999999999999999999 '' 2 '[1]a[2]b[3]a[4]b[5]a[6]' 6
      -999999999999999999999999999999 '*' 3 '[6]a[5]b[4]a[3]b[2]a[1]' 6
    End

    It '内外で同じバインド先を使っても結果と回数を保持すること'
      __sx_num_is_int_fit_dec() {
        case "${#}:${2-}" in 2:5 | 2:6 | 3:5 | 3:6) return 1;; esac
        return 0
      }
      cb_outer() {
        sx_str_sub res:cnt zz '' cb_replace '' 2
        __sx_var_set "${1}=[${5}]"
      }
      When call sx_str_sub res:cnt ababa "$2" cb_outer "$1" "$3"
      The status should be success
      The variable res should equal "$4"
      The variable cnt should equal "'$5'"
    End
  End

  It '元文字列長に安全範囲検査を適用しないこと'
    __sx_num_is_nat0_safe() {
      case "${1-}" in 3) return 1;; esac
      return 0
    }
    When call sx_str_sub res:cnt aba a X
    The status should be success
    The variable res should equal XbX
    The variable cnt should equal "'2'"
  End

  Context 'コールバックの結果変数を再入呼び出しに渡す場合'
    Parameters
      999999999999999999999999999999
      -999999999999999999999999999999
    End

    It '内側のコールバック置換結果を保持すること'
      cb_recursive() {
        sx_str_sub "${1}:" "${2}" '[a]' cb_replace '' 3
      }
      When call sx_str_sub res:cnt aabaa aa cb_recursive "$1" 2
      The status should be success
      The variable res should equal XXbXX
      The variable cnt should equal "'2'"
    End
  End

  It '結果未設定のコールバックでは前回の値を使わずマッチ文字列を保持すること'
    cb_optional() {
      case "${5}" in 1) __sx_var_set "${1}=X";; esac
    }
    When call sx_str_sub res:cnt aba a cb_optional '' 2
    The status should be success
    The variable res should equal Xba
    The variable cnt should equal "'2'"
  End

  It '検査省略時も巨大な負の制限を算術展開しないこと'
    SX_CFG_SKIP_CHK=1
    When call sx_str_sub res:cnt aba a X -999999999999999999999999999999
    The status should be success
    The variable res should equal XbX
    The variable cnt should equal "'2'"
  End
End
