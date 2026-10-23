# 明示した変数だけを戻すテスト準備

`setup.sh` の `sxtest_setup` は、別シェルで準備処理を実行し、指定した変数だけを呼び出し元へ戻します。
既存の `prepare.sh` の `sx_test_setup` とは独立しており、既存 spec の移行は行いません。

```sh
Include ./spec/support/setup.sh
Include ./spec/support/library.sh sx_arr_splice

It '中間の要素を置換すること'
  sxtest_setup items -- 'sx_arr_gen items "$@"' a b c
  When call sx_arr_splice items 1 1 x
  The status should be success
  The variable items_1 should equal x
End
```

構文は `sxtest_setup [変数名 ...] -- CMD [引数 ...]` です。

- 出力の変数名は0個以上。単純な変数名だけを受け付け、バインド形式は受け付けません。`SXTEST_*` は補助処理用の予約名です。
- `--` と空ではない CMD は必須です。呼出形式が不正なら、CMD を実行せず `64` を返します。
- CMD は1引数のシェルコードで、複数の関数呼び出しを記述できます。後続の引数は、空文字列・空白・改行を保持して CMD の位置パラメータへ渡します。
- 準備側は `SHELLSPEC_SHELL` のシェルと起動オプションに `-efu -o pipefail` を追加して起動し、全体版 `sx.sh` を読み込みます。事前にプロジェクトルートで `make all` を実行してください。
- 親の変数を収集・自動 export しません。通常の export 済み環境変数は継承します。必要な設定やリビジョンの開始値は、引数で渡して CMD 内で設定します。
- CMD の標準出力は標準エラーへ送ります。復元用のダンプだけを標準出力から捕捉します。
- 指定した変数を `sx_var_dump` で保存し、呼び出し元の `eval` で復元します。SX配列は関連要素と入れ子を含み、疎配列の未設定要素も保持します。関数定義や readonly 属性は転送しません。
- 設定・派生値・リビジョンも、出力名に指定したものだけを戻します。出力が0個なら CMD を実行し、変数は戻しません。
- 準備・ダンプが失敗した場合は、その終了状態を返して復元しません。`-e` の例外となる条件式や、判定関数の想定された `1` は、CMD 内で適切に扱います。CMD 内の `exit` は準備用シェルを終了させるため、後続のダンプも実行されません。
- 出力先が書き込み可能であることと、既存配列を再利用する前の後始末は、呼び出し側の責任です。復元途中の失敗に対するロールバックは行いません。

複数の準備処理は、同じ CMD 内にまとめられます。

```sh
sxtest_setup items result -- '
  sx_arr_gen items "$@"
  sx_arr_push items extra
  result=ready
' "${@}"
```

親のカウンタを引き継ぐ場合も、入力と出力を明示します。

```sh
sxtest_setup items SX_SYS_REV -- '
  SX_SYS_REV=$1
  shift
  sx_arr_gen items "$@"
' "${SX_SYS_REV-0}" "${@}"
```

検証対象は準備後に検証側で呼び出します。準備側で全体版を読み込んでも、その関数定義を検証側へ持ち込みません。
