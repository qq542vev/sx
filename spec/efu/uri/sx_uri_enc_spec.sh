# shellcheck shell=sh

Describe 'sx_uri_enc -efu 環境検証'
  sxtest_load ./build/modules/sx_uri_enc.sh

  Context '公開・内部・検証省略'
    Parameters
      sx_uri_enc 0
      sx_uri_enc 1
      __sx_uri_enc 0
    End

    It '入力省略を -efu 下で処理できる'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" res
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End

    It '保持文字だけの入力を -efu 下で処理できる'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" res 'abcXYZ012-._~'
      The status should be success
    End

    It '制御文字と保持区間の混在を -efu 下で処理できる'
      SX_CFG_SKIP_CHK=$2
      input=$(printf '\012a/b \011z%%')
      When run efu_run "$1" res "$input"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End

    It '複数入力の分配・配列・蓄積を -efu 下で処理できる'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" 'item_a:2@items:rest' 'a b' '' 'c/d' 'x+y' 'z%'
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End

    It 'バインド枯渇を -efu 下で成功として扱う'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" 'item_a:' 'a b' 'c/d'
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End

    It '空バインドを -efu 下で処理できる'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" '' 'a b'
      The status should be success
    End

    It '配列バインドの入力省略を -efu 下で処理できる'
      SX_CFG_SKIP_CHK=$2
      When run efu_run "$1" '@res'
      The status should be success
    End
  End

  It 'バインド形式の省略を -efu 下で拒否する'
    When run efu_run sx_uri_enc
    The status should equal 64
  End

  It '不正なバインド形式を -efu 下で拒否する'
    When run efu_run sx_uri_enc 'res;command' input
    The status should equal 64
  End

  It '読み取り専用の結果変数を -efu 下で拒否する'
    readonly res=before
    When run efu_run sx_uri_enc res input
    The status should equal 77
    The stderr should equal ''
  End

  It '後続スロットが読み取り専用なら -efu 下でも拒否する'
    readonly item_b=before
    When run efu_run sx_uri_enc 'item_a:item_b:' a b
    The status should equal 77
    The stderr should equal ''
  End

  It '数値範囲設定が不正なら -efu 下で拒否する'
    SX_CFG_NUM_RANGE=invalid
    When run efu_run sx_uri_enc res a
    The status should equal 78
  End
End
