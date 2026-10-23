# 明示した変数だけを戻すテスト補助処理

`setup.sh` の `sxtest_setup` は、別シェルで補助処理を実行し、指定した変数だけを呼び出し元へ戻します。
事前準備と事後検証にはこのヘルパーを使います。`prepare.sh` の `sx_test_setup` は、コールバック・後始末と旧ヘルパー自身のテストに残しています。

```sh
Include ./spec/support/setup.sh
Include ./spec/support/library.sh sx_arr_splice

It '中間の要素を置換すること'
  sxtest_setup items SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen items "$@"' "${SX_SYS_REV-0}" a b c
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
- 親の変数を収集・自動 export しません。通常の export 済み環境変数は継承します。事前準備で必要な設定やリビジョンの開始値は、引数で渡して CMD 内で設定します。
- CMD の標準出力は標準エラーへ送ります。復元用のダンプだけを標準出力から捕捉します。
- 指定した変数を `sx_var_dump` で保存し、呼び出し元の `eval` で復元します。SX配列は関連要素と入れ子を含み、疎配列の未設定要素も保持します。関数定義や readonly 属性は転送しません。
- 設定・派生値・リビジョンも、出力名に指定したものだけを戻します。出力が0個なら CMD を実行し、変数は戻しません。
- 準備・ダンプが失敗した場合は、その終了状態を返して復元しません。`-e` の例外となる条件式や、判定関数の想定された `1` は、CMD 内で適切に扱います。CMD 内の `exit` は準備用シェルを終了させるため、後続のダンプも実行されません。
- 出力先が書き込み可能であることと、既存配列を再利用する前の後始末は、呼び出し側の責任です。復元途中の失敗に対するロールバックは行いません。

複数の準備処理は、同じ CMD 内にまとめられます。

生成した配列への追加や削除が続く場合も、一連のデータ準備を同じ CMD で実行します。検証対象の呼び出し、検証用の関数定義、readonly 属性の設定は検証側に置きます。リビジョンの継続が必要な場合は、カウンタの入力と出力も明示します。

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

## 事後検証

検証対象が生成した変数を子で読み取る場合は、ShellSpec の `Set 'allexport:on'` を指定します。
判定だけなら出力変数を指定せず、`Assert sxtest_setup -- CMD` を使います。

```sh
Describe 'sx_csv_parse'
  Include ./spec/support/setup.sh
  Include ./spec/support/library.sh sx_csv_parse

  It '解析結果をSX配列として保存すること'
    Set 'allexport:on'
    When call sx_csv_parse res 'a,b'
    The status should be success
    Assert sxtest_setup -- 'sx_var_is_arr res res_0'
  End
End
```

現在の ShellSpec では `Set` のオプションは `When` の実行時に適用されます。
それ以前に作った変数や、対象の処理で代入されない既存要素は、必要な名前を明示的に export します。
SX配列ではルート・長さ・各要素、入れ子があればその構成変数も対象です。
`When` を使わずに整合性を検証する場合も、入力を明示的に export します。
親で変更した設定を子でも使う場合は、必要な `SX_CFG_*` も export します。

```sh
# itemsは事前に生成した2要素の配列。変更されない要素も子へ渡す。
export items items_len items_0 items_1
```

比較用の値が必要なら、出力名を明示して受け取れます。

```sh
sxtest_setup result -- 'sx_arr_quote result items'
The variable result should equal "'a' 'b'"
```

一般変数の収集や自動 export はヘルパーに追加しません。
子での判定が `1` を返す場合も、その終了状態を呼び出し元へ返します。
親の readonly 属性や、親と同じ実行状態での干渉を調べる場合は、検証側で直接確認します。
