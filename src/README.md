# 分割ソースとビルド

`src/*` と `m4/common.m4` がライブラリのソースです。`sx.sh` は生成物です。
定数・大域変数・関数の定義と、その直接依存 `M_REQUIRE` を各 `.m4` ファイルで編集します。
共通マクロと定数値マクロは `m4/common.m4` で編集します。

```text
m4/
├── common.m4       共通マクロとビルド時の定数値
└── resolve.m4      選択と依存解決
src/
├── constants.m4    定数の一覧と出力順
├── constants/      定数ごとのファイル
├── globals.m4      大域変数の初期化順
├── globals/        大域変数ごとのファイル
├── functions.m4    関数の一覧と出力順
└── functions/      公開・内部関数ごとのファイル
```

各一覧には `M_UNIT([|名前|], [|パス|])` を一単位につき一行登録します。
新規ファイルを追加したときは対応する一覧にも追加してください。
全体版と部分版は同じ一覧を使用し、出力順は定数、大域変数、関数の順です。

```sh
make
make SX_SYMBOLS=
make SX_SYMBOLS=sx_uri_enc
make SX_SYMBOLS='sx_uri_enc sx_uri_is_pct' SX_OUT=build/uri.sh
make SX_SYMBOLS=sx_uri_enc bundle
```

`SX_SYMBOLS` を省略するか空文字列にすると全単位を含めます。
指定時には名前を空白1文字で区切り、指定した単位と依存先だけを含めます。
既定の出力先は `sx.sh` で、`SX_OUT` で変更できます。
`all` と `bundle` は同じ生成処理を使います。
毎回生成するため、同じ出力先で選択内容を変えても古い定義は残りません。
`make test` は選択指定にかかわらず全体版を生成して検証します。

```sh
make modules SX_SYMBOLS=sx_uri_enc
make modules SX_SYMBOLS='sx_uri_enc sx_uri_is_pct'
shellspec spec/modules/uri_enc_spec.sh
```

`modules` は指定名ごとに依存先を含む `build/modules/<名前>.sh` を生成します。
`SX_SYMBOLS` の明示が必要で、`SX_OUT` は使いません。
各ファイルは単独で読み込みます。複数の名前を同じシェルで利用するときは、
通常のバンドルでそれらを一つにまとめてください。
同じ名前は毎回再生成し、今回指定していない名前のファイルは保持します。
`make clean` は個別生成物も削除します。
全ての実行時テストは、既定で個別モジュールを読み込みます。
テストが補助API・定数・設定値を必要とするときは、読み込み行に名前を明示します。
製品側の `M_REQUIRE` にはテスト専用の依存を追加しません。

```sh
make test-modules
# 対象だけを再生成することもできる。
make test-modules SX_SPECS=spec/arr/push_spec.sh
shellspec spec/arr/push_spec.sh
SX_TEST_MODE=full shellspec spec/arr/push_spec.sh
```

検証側では、対象の提供名を一つ指定します。準備用APIは別シェルで実行し、
結果の変数だけを復元します。

```sh
Describe 'sx_arr_push'
  Include ./spec/support/setup.sh
  Include ./spec/support/library.sh sx_arr_push

  It '末尾に要素を追加すること'
    sxtest_setup items SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen items "$@"' "${SX_SYS_REV-0}" a b
    When call sx_arr_push items c
    The status should be success
    The variable items_2 should equal c
  End
End
```

`make test-modules` は各テストの宣言から提供名を収集し、
`build/modules/<名前>.sh` を名前ごとに一度だけ生成します。
各モジュールには対象と宣言済みの依存先を含めます。
`Include ./build/modules/sx_uri_enc.sh` の直接指定も収集対象です。
複数のグループやファイルで同じ名前を指定しても、生成は重複しません。
提供名の収集は Python、依存解決は既存の m4 生成器が担当します。
事前準備・事後検証・コールバックの補助処理・後始末は [setup.md](../spec/support/setup.md) を参照してください。
旧ヘルパー自身のテストで維持している挙動は [prepare.md](../spec/support/prepare.md) に記載しています。

全体版との比較には `SX_TEST_MODE=full` を指定し、ShellSpec を起動し直します。
この場合は先に `make all` で全体版を生成してください。
`make test` は全体版とテストに必要な単独モジュールを生成し、全テストを個別版・全体版でそれぞれ実行します。
ShellSpec のオプションは `make test TEST_FLAGS='--jobs 4'` のように指定できます。
`make clean` はテスト用の生成物も削除します。

依存は各ファイル先頭の `M_REQUIRE([|...|])dnl` に直接参照する実行時の名前を列挙します。
依存がないときも `M_REQUIRE([||])dnl` を一行置きます。
ビルド時マクロ `M_*` は列挙しません。例えば `sx_uri_enc` は、内部実装や設定など直接参照する名前を宣言します。
関数間の循環は許し、初期化を含む循環、未知の名前、名前の重複はエラーにします。
出力前に依存をたどり、訪問済みの単位を一度だけ含めます。

```sh
python3 tools/check-units.py
python3 tools/check-dependencies.py
```

前者は一覧と実ファイルの対応、後者は依存宣言と展開後の参照を検査します。
依存宣言の更新を意図するときに限り `python3 tools/check-dependencies.py --write` を使えます。
`m4/common.m4` は実行時コードを出力しません。
定数は `M_CONST` で出力し、シェルで引用が必要な値には `M_SH_QUOTE` を使います。
大域変数は環境から継承した設定値と空文字を保持し、数値の派生値を個別に初期化します。
関数は `M_RENAME_Q/QI` と `CLEANUP` のスコープを各ファイル内で管理します。
