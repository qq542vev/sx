# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
Describe 'sx_str_pad -efu 環境検証'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_str_pad.sh

  It '正常動作'

    When run efu_run sx_str_pad res "A" 3 ""
    The status should be success
  End

  Context '符号と埋め込み方向'
    Parameters
      '+5'
      '-5'
      '+0'
      '-0'
    End

    It '外部コマンドなしで正常に終了すること'
      When run efu_run sx_str_pad res 'A' "$1" 'xyz'
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '長さを省略しても正常に終了すること'
    When run efu_run sx_str_pad res 'ABC'
    The status should be success
    The stderr should equal ''
  End

  Context '算術域を超える幅'
    Before 'sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR -- "sx_cfg_set NUM_RANGE=32"'

    Parameters
      '+2147483648'
      '-2147483648'
      '+9223372036854775808'
      '-9223372036854775808'
      '-1000000000000000000000000000000'
    End

    It '空の埋め込み文字列で正常に終了すること'
      When run efu_run sx_str_pad res 'ABC' "$1" ''
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End

    It '巨大な出力を生成せず多倍長計算を完了できること'
      # 算術エラーによるシェル終了を検出しつつ、巨大な出力の割り当てを防ぐ。
      __sx_str_rep() { eval "${1}="; }
      When run efu_run sx_str_pad res 'A' "$1" 'xyz'
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '不正な幅'
    Parameters
      # ShellSpec の入力データとして空文字列を指定する。
      # shellcheck disable=SC2286
      ''
      '010'
      '0x3'
      '1.5'
      '+'
    End

    It '64で拒否すること'
      When run efu_run sx_str_pad res 'A' "$1" ''
      The status should equal 64
      The stderr should equal ''
    End
  End
End
