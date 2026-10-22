# shellcheck shell=sh
# 値は準備専用シェルから参照渡しで設定する。
# shellcheck disable=SC2154

Describe '別シェルでのテスト準備'
  Include ./spec/support/prepare.sh
  Include ./spec/support/library.sh sx_var_is_name

  It '空文字列・引用符・改行・メタ文字をそのまま復元すること'
    tail='first
last
'
    When call sx_test_setup sx_arr_gen items '' "it's * ?" "$tail"
    The status should be success
    The variable items_len should equal 3
    The variable items_0 should equal ''
    The variable items_1 should equal "it's * ?"
    The variable items_2 should equal "$tail"
  End

  It '準備側で削除した配列の要素も復元側から削除すること'
    sx_test_setup sx_arr_gen items a b c
    When call sx_test_setup sx_var_unset items
    The status should be success
    The variable items should be undefined
    The variable items_len should be undefined
    The variable items_0 should be undefined
    The variable items_1 should be undefined
    The variable items_2 should be undefined
  End

  It '準備側へ渡した疎配列の穴を保持すること'
    sx_test_setup sx_arr_gen items a b c
    unset items_1
    When call sx_test_setup sx_arr_quote encoded items
    The status should be success
    The variable encoded should equal "'a' '' 'c'"
    The variable items_1 should be undefined
  End

  It '明示した設定を戻しても対象が持たない数値派生値を追加しないこと'
    had_num_wlen=${SX_SYS_NUM_WLEN+x}
    When call sx_test_setup sx_cfg_set NUM_RANGE=64
    The status should be success
    The variable SX_CFG_NUM_RANGE should equal 64
    case "$had_num_wlen" in
      x)
        The variable SX_SYS_NUM_WLEN should equal 18
        ;;
      *)
        The variable SX_SYS_NUM_WLEN should be undefined
        ;;
    esac
  End

  It '準備側のエラーを成功扱いにしないこと'
    When call sx_test_setup sx_arr_gen invalid-name a
    The status should equal 64
    The stdout should equal ''
    The stderr should equal ''
  End
End

Describe '準備と対象実行のリビジョン'
  Include ./spec/support/prepare.sh
  Include ./spec/support/library.sh sx_var_touch

  It '準備後のカウンタを対象の実行へ引き継ぐこと'
    SX_SYS_REV=7
    sx_test_setup sx_arr_gen items a
    prepared_rev=$SX_SYS_REV
    When call sx_var_touch items
    The status should be success
    The variable prepared_rev should equal 8
    The variable items should end with ':8'
    The variable SX_SYS_REV should equal 9
  End
End
