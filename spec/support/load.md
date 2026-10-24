# 個別モジュールの読み込み

`spec/spec_helper.sh` の `sxtest_load [mod ...]` は、指定順に
`build/modules/<mod>.sh` を現在のシェルへ読み込みます。
ShellSpec では `.shellspec` によって関数が自動的に利用可能になります。
モジュールは事前に生成してください。

```sh
make modules SX_SYMBOLS='sx_uri_enc sx_uri_is_pct'
```

```sh
sxtest_load sx_uri_enc sx_uri_is_pct
```

`SXTEST_LOAD_MOD` が設定済みなら、引数の一覧をその値で置き換えます。
区切りは空白1文字で、連続する空白や先頭・末尾の空白は読み飛ばします。
設定値が空文字または空白だけなら、何も読み込まず成功します。
未設定で引数もない場合も成功します。

```sh
SXTEST_LOAD_MOD='sx_uri_is_pct sx_uri_enc' sxtest_load sx_uri_enc
SXTEST_LOAD_MOD='' sxtest_load sx_uri_enc  # 読み込みなし
```

提供名は英数字と `_` だけを認め、先頭の数字・空文字・パス形式は `64` で拒否します。
呼び出し元の `IFS` やパス名展開の設定には依存せず、設定は読み込み前に復元します。
読み込めないファイルは `1`、読み込み先の失敗はその終了状態を返し、後続を読み込みません。
それ以前に読み込んだ定義や状態は保持します。

重複の検出・回避は行いません。依存先を共有する複数のモジュールでは、
定数や大域変数の初期化も再実行されます。
従来の `library.sh` と `SX_TEST_MODE` による読み込みは引き続き利用できます。
新しい関数は `SX_TEST_MODE` にかかわらず指定された個別モジュールを読み込みます。
既存specの移行と、specに依存しないモジュール生成方式への変更は別途行います。
