# モジュールファイルの読み込み

`spec/spec_helper.sh` の `sxtest_load [mod ...]` は、指定したファイルを
指定順に現在のシェルへ読み込みます。`mod` はファイルのパスです。
ShellSpec では `.shellspec` によって関数が自動的に利用可能になります。
モジュールは事前に生成してください。

```sh
make module.mk
make -f module.mk build/modules/sx_uri_enc.sh build/modules/sx_uri_is_pct.sh
```

```sh
sxtest_load ./build/modules/sx_uri_enc.sh ./build/modules/sx_uri_is_pct.sh
```

`SXTEST_LOAD_MOD` が設定済みなら、引数の一覧をその値で置き換えます。
区切りは空白1文字で、連続する空白や先頭・末尾の空白は読み飛ばします。
設定値が空文字または空白だけなら、何も読み込まず成功します。
未設定で引数もない場合も成功します。

```sh
SXTEST_LOAD_MOD='build/modules/sx_uri_is_pct.sh build/modules/sx_uri_enc.sh' sxtest_load ./build/modules/sx_uri_enc.sh
SXTEST_LOAD_MOD='' sxtest_load ./build/modules/sx_uri_enc.sh  # 読み込みなし
```

相対パスは作業ディレクトリを基準に読み込みます。`sx.sh` のように名前だけを指定した場合も
`PATH` は検索しません。絶対パスも指定でき、空白を含むパスは引数で引用して渡せます。
環境変数の一覧には、空白を含むパスを指定できません。
空文字の引数は `64` で拒否します。
呼び出し元の `IFS` やパス名展開の設定には依存せず、設定は読み込み前に復元します。
存在しないファイル・ディレクトリ・読み込めないファイルは `1`、読み込み先の失敗はその終了状態を返し、後続を読み込みません。
それ以前に読み込んだ定義や状態は保持します。

重複の検出・回避は行いません。依存先を共有する複数のモジュールでは、
定数や大域変数の初期化も再実行されます。
モジュールの生成対象は `src` から列挙するため、specの記述には依存しません。

全体版の検証では、読み込み先を `sx.sh` に置き換えます。
事前に `make all` で全体版を生成してください。

```sh
SXTEST_LOAD_MOD=sx.sh shellspec
```

`make test` はこの変数を未設定にした個別版の検証と、`sx.sh` を指定した全体版の検証を実行します。
