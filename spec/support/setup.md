# 明示した変数だけを戻すテスト補助処理

`setup.sh` の `sxtest_setup` は、別シェルで補助処理を実行し、指定した変数だけを呼び出し元へ戻します。
事前準備・事後検証・コールバックの補助処理・後始末にはこのヘルパーを使います。
`prepare.sh` の `sx_test_setup` は、旧ヘルパー自身のテストに残しています。

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

構文は `sxtest_setup [変数名|名前=値 ...] -- CMD [引数 ...]` です。

- 出力の変数名は0個以上。単純な変数名だけを受け付け、バインド形式は受け付けません。`SXTEST_*` は補助処理用の予約名で、出力先・環境変数名には指定できません。
- `--` の前には、出力変数名と `名前=値` 形式の環境変数指定を混在できます。環境変数指定は子の起動時に適用され、出力名にも指定しない限り親へは戻しません。同名の継承済み環境変数があれば、指定した値で上書きします。
- `--` と CMD 引数は必須ですが、CMD の空文字列は許可します。空CMDでも `sx.sh` の読み込みと指定した変数のダンプは行います。CMD 引数自体の省略など、呼出形式が不正なら、子のコマンドを起動せず `64` を返します。
- CMD は1引数のシェルコードで、複数の関数呼び出しを記述できます。後続の引数は、空文字列・空白・改行を保持して CMD の位置パラメータへ渡します。
- 準備側は `SHELLSPEC_SHELL` のシェルと起動オプションに `-efu -o pipefail` を追加して起動し、全体版 `sx.sh` を読み込みます。事前にプロジェクトルートで `make all` を実行してください。
- 親の変数を収集・自動 export しません。通常の export 済み環境変数は継承し、必要な入力だけを `名前=値` または位置引数で渡します。`sx.sh` の読み込み時に初期化される `SX_SYS_REV` などの開始値は、位置引数で渡して CMD 内で設定します。
- CMD の標準出力は標準エラーへ送ります。復元用のダンプだけを標準出力から捕捉します。
- 指定した変数を `sx_var_dump` で保存し、呼び出し元の `eval` で復元します。SX配列は関連要素と入れ子を含み、疎配列の未設定要素も保持します。関数定義や readonly 属性は転送しません。
- 設定・派生値・リビジョンも、出力名に指定したものだけを戻します。出力が0個なら CMD を実行し、変数は戻しません。
- 準備・ダンプが失敗した場合は、その終了状態を返して復元しません。`-e` の例外となる条件式や、判定関数の想定された `1` は、CMD 内で適切に扱います。CMD 内の `exit` は準備用シェルを終了させるため、後続のダンプも実行されません。
- 出力先が書き込み可能であることと、既存配列を再利用する前の後始末は、呼び出し側の責任です。復元途中の失敗に対するロールバックは行いません。

環境変数を明示して子で利用し、指定した結果だけを戻せます。

```sh
sxtest_setup INPUT='a b' result -- 'result=$INPUT'
sxtest_setup -- ''  # 空CMD・出力なし。ライブラリの読み込みだけを行う。
```

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

## コールバックの補助処理

補助代入や大文字変換、多倍長加算も、結果変数と入力値を明示して実行できます。
次のコールバックでは `$1` が単純な結果変数名です。入力は引数で渡すため、`allexport` は不要です。

```sh
cb() {
  sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=[$2]"
}

upper_cb() {
  sxtest_setup "$1" -- 'sx_str_upper "$@"' "$1" "$2"
}

sum_cb() {
  sxtest_setup "$1" -- 'sx_num_add_int "$@"' "$1" "$2" "$3"
}
```

呼び出し回数の記録、スキップ、中断の判定はコールバック本体に残します。
再入を検証する対象関数も、親の同じシェル内で呼びます。
バインド形式を出力名に指定することはできません。

## 後始末

設定を既定値に戻す場合は、戻す設定変数だけを出力に指定します。

```sh
sxtest_setup SX_CFG_ARR_REF -- 'sx_cfg_set ARR_REF'
```

構成が固定された配列を削除する場合は、ルートだけでなく長さと各要素も出力に指定し、子で削除します。
この例では全削除名を引数でも渡すため、親の配列値を子へ転送する必要はありません。

```sh
# itemsは2要素の配列。各変数の未設定状態を親へ戻す。
sxtest_setup items items_len items_0 items_1 -- \
  'sx_var_unset "$@"' items items_len items_0 items_1
```

子で配列を削除してからルートだけをdumpしても、削除済みの関連要素名は取得できません。
疎配列の未設定要素や入れ子も含め、親で削除すべき構成変数を明示してください。
