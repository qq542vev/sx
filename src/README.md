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
make module.mk
make -f module.mk build/modules/sx_uri_enc.sh
make -f module.mk build/modules/sx_uri_enc.sh build/modules/sx_uri_is_pct.sh
shellspec spec/modules/uri_enc_spec.sh
```

`make module.mk` は `find` で `src/constants/`・`src/globals/`・`src/functions/`
配下の `.m4` を列挙し、対応する `build/modules/<提供名>.sh` のルールを生成します。
公開関数・内部関数・定数・大域変数の全単位を対象とし、一覧ファイルとREADMEは対象外です。
各モジュールは対象とその依存先を含め、既存のm4生成器で作成します。
`module.mk` は生成物で、Git管理の対象外です。直接編集しないでください。

`make -f module.mk` は全単位、ターゲット指定時は指定したモジュールを生成します。
各モジュールは全単位のソース・一覧・共通ビルドファイルに依存します。
未変更なら再生成せず、いずれかを変更した後の全件生成では全単位を再生成します。
個別ターゲット指定時は、その対象だけを再生成します。
生成対象はspecの記述や `SX_SYMBOLS`・`SX_OUT` に依存しません。

```sh
make module
make -j4 module
shellspec spec/arr/push_spec.sh
SXTEST_LOAD_MOD=sx.sh shellspec spec/arr/push_spec.sh
```

`make module` は一覧を更新してから `make -f module.mk` を呼び出します。
`make -f module.mk` の直接実行は生成済みの一覧を使い、ソースの追加・削除を自動反映しません。
追加・削除後は `make module.mk` または `make module` を実行してください。
一覧が同じなら `module.mk` の更新時刻を保持します。
`make clean` は `module.mk` と個別生成物も削除します。

各ファイルは単独で読み込みます。複数の名前を同じシェルで利用するときは、
通常のバンドルでそれらを一つにまとめてください。
全ての実行時テストは、既定で個別モジュールを読み込みます。
製品側の `M_REQUIRE` にはテスト専用の依存を追加しません。
検証側では、対象のモジュールファイルを指定します。準備用APIは別シェルで実行し、
結果の変数だけを復元します。

```sh
Describe 'sx_arr_push'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_arr_push.sh

  It '末尾に要素を追加すること'
    sxtest_run items SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen items "$@"' "${SX_SYS_REV-0}" a b
    When call sx_arr_push items c
    The status should be success
    The variable items_2 should equal c
  End
End
```

事前準備・事後検証・コールバックの補助処理・後始末は [run.md](../spec/support/run.md) を参照してください。

モジュールファイルの読み込みには `spec_helper.sh` の `sxtest_load` を使います。
引数と `SXTEST_LOAD_MOD` による指定は [load.md](../spec/support/load.md) を参照してください。

全体版との比較には `SXTEST_LOAD_MOD=sx.sh` を指定し、ShellSpec を起動し直します。
この場合は先に `make all` で全体版を生成してください。
`make test` は全体版と全単位のモジュールを生成し、全テストを個別版・全体版でそれぞれ実行します。
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
