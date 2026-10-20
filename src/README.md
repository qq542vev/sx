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
