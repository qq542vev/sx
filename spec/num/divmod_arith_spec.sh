#!/bin/sh
# ShellSpecのParameters内の値をシェルコードとして解釈する診断を抑制する。
# shellcheck disable=SC2016,SC2215,SC2286,SC2288

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_divmod_arith'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '商と余り'
    Parameters
      0 0
      42 0 42
      0 0 '' ''
      7 0 7 ''
      0 0 '' -2
      3 1 7 2
      -3 1 7 -2
      -3 -1 -7 2
      3 -1 -7 -2
      0 -1 -1 2
      -3 0 -6 2
      0 0 -0 -2
      0 0 +0x0 -01
      2 2 +010 0x3
      -2 -2 -010 +0X3
      3 1 7 2 ignored
      -2147483648 0 -2147483648 1
      -1073741824 0 -2147483648 2
      -715827882 -2 -2147483648 3
      1 0 -2147483648 -2147483648
      -1 -1 -2147483648 2147483647
      0 2147483647 2147483647 -2147483648
      -2147483647 0 2147483647 -1
      -1073741824 0 -0x80000000 +02
    End

    It "引数列 $* の商が $1、余りが $2 になること"
      expected_q="$1" expected_r="$2"
      shift 2
      When call sx_num_divmod_arith 'q:r:' "$@"
      The status should be success
      The variable q should equal "$expected_q"
      The variable r should equal "$expected_r"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '安全に計算できない入力'
    Parameters
      7 0
      7 +0
      7 -0
      7 00
      7 -00
      7 +0x0
      7 -0X0
      -2147483648 -1
      -0x80000000 -01
      -020000000000 -0X1
    End

    It "引数列 $* を64で拒否してバインド先を変更しないこと"
      q=old_q r=old_r
      When call sx_num_divmod_arith 'q:r:' "$@"
      The status should equal 64
      The variable q should equal old_q
      The variable r should equal old_r
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '形式不正または入力範囲外'
    Parameters
      abc
      +
      --1
      1.5
      08
      0xG
      '1+2'
      '$(q=changed)'
      '1;q=changed'
      2147483648
      -2147483649
      0x80000000
      -020000000001
    End

    It "被除数 $1 を64で拒否すること"
      q=old_q r=old_r
      When call sx_num_divmod_arith 'q:r:' "$1" 2
      The status should equal 64
      The variable q should equal old_q
      The variable r should equal old_r
      The stderr should equal ''
    End

    It "除数 $1 を64で拒否すること"
      q=old_q r=old_r
      When call sx_num_divmod_arith 'q:r:' 7 "$1"
      The status should equal 64
      The variable q should equal old_q
      The variable r should equal old_r
      The stderr should equal ''
    End
  End

  It '結果変数を省略した場合は64になること'
    When call sx_num_divmod_arith
    The status should equal 64
  End

  It '不正なバインドを64で拒否すること'
    When call sx_num_divmod_arith 'bad-name:r:' 7 2
    The status should equal 64
  End

  It '余りの書き込み先がreadonlyの場合も商を変更しないこと'
    q=old_q
    readonly ro_divmod_arith=old_r
    When call sx_num_divmod_arith 'q:ro_divmod_arith:' 7 2
    The status should equal 77
    The variable q should equal old_q
    The variable ro_divmod_arith should equal old_r
  End

  It '商のみのバインドでも成功すること'
    When call sx_num_divmod_arith 'q:' 7 2
    The status should be success
    The variable q should equal 3
  End

  It '商をスキップして余りだけを格納できること'
    When call sx_num_divmod_arith ':r:' -7 2
    The status should be success
    The variable r should equal -1
  End

  It '蓄積先に商と余りを格納できること'
    result=old
    When call sx_num_divmod_arith result -7 2
    The status should be success
    The variable result should equal '-3 -1'
  End

  It '空のバインドでは結果を破棄して成功すること'
    When call sx_num_divmod_arith '' 7 2
    The status should be success
  End

  It '配列を初期化して商と余りを格納できること'
    sx_arr_gen items old extra stale
    When call sx_num_divmod_arith '@items' 7 2
    The status should be success
    The variable items_len should equal 2
    The variable items_0 should equal 3
    The variable items_1 should equal 1
  End

  It '検証失敗時は配列の要素とリビジョンも変更しないこと'
    sx_arr_gen items old
    old_signature="${items-}"
    When call sx_num_divmod_arith '@items' 7 0
    The status should equal 64
    The variable items should equal "$old_signature"
    The variable items_len should equal 1
    The variable items_0 should equal old
  End

  Context 'intとの切替互換性'
    Parameters
      7 2
      -7 2
      7 -2
      -7 -2
      -2147483648 3
      2147483647 -1
    End

    It "引数列 $* で同じ商と余りを返すこと"
      sx_num_divmod_int 'expected_q:expected_r:' "$@"
      type=arith
      When call "sx_num_divmod_${type}" 'q:r:' "$@"
      The status should be success
      The variable q should equal "$expected_q"
      The variable r should equal "$expected_r"
    End
  End

  Context '不正な設定'
    Parameters
      ''
      invalid
      16
    End

    It "設定 $1 を78で拒否して結果を変更しないこと"
      SX_CFG_NUM_RANGE="$1"
      q=old_q r=old_r
      When call sx_num_divmod_arith 'q:r:' 7 2
      The status should equal 78
      The variable q should equal old_q
      The variable r should equal old_r
    End
  End

  It 'チェック省略時も安全な除算を実行できること'
    SX_CFG_SKIP_CHK=1
    When call sx_num_divmod_arith 'q:r:' -010 0x3
    The status should be success
    The variable q should equal -2
    The variable r should equal -2
  End

  Context '64ビット設定'
    arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Context '商と余り'
      Parameters
        -9223372036854775808 0 -9223372036854775808 1
        -3074457345618258602 -2 -9223372036854775808 3
        1 0 -9223372036854775808 -9223372036854775808
        -1 -1 -9223372036854775808 9223372036854775807
        -9223372036854775807 0 9223372036854775807 -1
        -4611686018427387904 0 -0x8000000000000000 02
      End

      It "引数列 $* の商が $1、余りが $2 になること"
        expected_q="$1" expected_r="$2"
        shift 2
        When call sx_num_divmod_arith 'q:r:' "$@"
        The status should be success
        The variable q should equal "$expected_q"
        The variable r should equal "$expected_r"
      End
    End

    It '最小値を-1で割る前に64で拒否すること'
      q=old_q r=old_r
      When call sx_num_divmod_arith 'q:r:' -0x8000000000000000 -01
      The status should equal 64
      The variable q should equal old_q
      The variable r should equal old_r
      The stderr should equal ''
    End
  End
End
