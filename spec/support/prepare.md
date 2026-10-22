# 単独モジュールのテスト準備

`prepare.sh` の `sx_test_setup` は、準備用の関数を別シェルで実行し、結果の変数だけを呼び出し元へ戻します。

```sh
Describe 'sx_arr_splice'
  Include ./spec/support/prepare.sh
  Include ./spec/support/library.sh sx_arr_splice

  It '配列を置換すること'
    sx_test_setup sx_arr_gen items a b c
    When call sx_arr_splice items 1 1 x
    The status should be success
    The variable items_1 should equal x
  End
End
```

準備側は `sh -efu` で新しく起動し、全体版の `sx.sh` を読み込みます。検証側の関数やスタブは引き継ぎません。検証側には対象の単独モジュールとその宣言済み依存先だけが定義されるため、準備で使う `sx_arr_gen` などによって依存不足が隠れることを防げます。既存の Parameters や Before/BeforeEach はそのまま利用できます。

- 入力の変数値は環境変数で渡し、出力は `sx_var_dump` の代入式で復元します。空文字列、引用符、末尾の改行、入れ子の配列、疎配列を保持します。
- 通常は第1引数の結果変数・バインド先を戻します。`sx_var_bind_init`、`sx_var_set`、`sx_var_unset` は全引数、`sx_arr_get` は結果と元配列を対象にします。準備側で削除した要素も、復元側で unset します。
- `sx_cfg_set` / `__sx_cfg_set` の明示的な設定変更を戻します。数値派生値とリビジョンは、検証側ですでに定義されているものだけを更新します。カウンタを持たない raw 操作で更新の有無を観測する場合は、検証側で監視用の `SX_SYS_REV` を先に用意します。
- 数値境界を入力に使うテストには、対象モジュールの依存先を増やさずに済むよう `SXTEST_NUM_MIN` / `SXTEST_NUM_MAX` を戻します。
- 準備で失敗した場合は終了状態を呼び出し元へ返します。

これはテスト準備用の共通処理です。検証対象の呼び出しは `When call sx_...` / `When run efu_run sx_...` のままにし、`sx_test_setup` へ移しません。複数の機能を検証するファイルでは、読み込み関数の中に静的な Include を宣言し、Example ごとに対象だけを選びます。ShellSpec は Example 内に直接書いた Include を受け付けません。

プロジェクトルートから、先に `make all` と対象の `make test-modules SX_SPECS=...` を実行してください。`SX_TEST_MODE=full` でも準備方法は同じで、検証側の読み込みだけが全体版に切り替わります。
