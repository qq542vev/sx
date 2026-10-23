# 自己呼び出しによる単独モジュールの依存検証（試作）

```sh
make all
make test-modules SX_SPECS=spec/dep/arr/splice_spec.sh
shellspec spec/dep/arr/splice_spec.sh
```

`test-modules` はこのspecの明示的なIncludeから
`build/modules/sx_arr_splice.sh` を生成する。
代わりに `make modules SX_SYMBOLS=sx_arr_splice` でも準備できる。

環境変数 `SXTEST_DEP_FIXTURE` が未設定なら、親用の2つのExampleを実行する。
親はExample実行時に `sxtest_setup` を使い、配列生成と `sx_var_dump` を
準備用シェルの同じCMDで実行する。fixtureのシェルコードだけを親へ戻し、
新しいShellSpecへその値を渡して同じspecだけを実行する。
子は対象モジュールだけを読み込み、各Exampleの前に入力を復元する。
`spec_helper` の -efu と漏洩検査を共有する。

親子のContextは `Skip if` で選択する。親の結果は8 examples / 6 skips、
子の正常結果は8 examples / 2 skipsとなる。親は子の終了状態と集計の両方を
検査し、子の全件スキップを成功とみなさない。Exampleを増減するときは集計の
期待値も更新する。子の出力は親のWhenに捕捉され、失敗時の診断として表示される。

もう一つの親ExampleはShellSpecの作業ディレクトリに対象のコピーを作り、
読み込み時に `__sx_arr_splice_raw` を除去する。子がShellSpecの失敗状態101を
返し、診断に欠落した関数名が含まれることを検査する。元の生成物は変更しない。

子の環境は入力・対象パス・PATH・HOME・ロケールに限定する。プロジェクトの
`.shellspec` は引き続き利用する。現在の環境ではshがyashのPOSIXラッパーなので、
子も既存設定と同じ `--shell sh` を使う。個人用のShellSpec設定ファイルはHOME
から読み込まれ得るため、この試作は任意のユーザー設定からの完全隔離は保証しない。

通常の動作テストと既存のPython実験は維持している。この試作は選んだ実行経路の
依存を検査するもので、全経路や直接依存宣言の正しさを保証するものではない。
