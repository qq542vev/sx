# spec 配下の Python テストの ShellSpec 移行

期待値の根拠は現在の AGENTS.md、公開 API の仕様、および今回の合意とする。
旧 Python の実装や期待値そのものを仕様として採用しない。
Makefile には名前の形式・重複によるフィルタリングや拒否を追加しない。
`tools/*.py` は移行対象外であり、検査ツールの CLI 呼び出しは残す。

| 旧ファイル・検証目的 | 移行先・扱い |
| --- | --- |
| units_test.py: 欠落・未登録・重複・名前とパスの不一致 | units_spec.sh の独立した異常系。検査ツールを一時プロジェクトへコピーして CLI で検査する |
| modules_test.py: 単独・複数生成、依存関係、実行、生成失敗時の出力保持、未知のターゲット | modules_spec.sh で維持 |
| modules_test.py: 全単位生成、直接 module.mk の実行、指定した対象だけの再生成、共通ファイル変更後の生成 | modules_spec.sh で維持。時刻比較は内容を壊して再生成結果を比較する方式へ変更 |
| modules_test.py: 未変更なら再生成しない | 毎回生成する現在の仕様に修正 |
| modules_test.py: ソース追加・削除後の一覧更新、clean、廃止ターゲットの拒否 | modules_spec.sh で維持 |
| modules_test.py: 生成したライブラリに実行権限がある | 実行権限不要の方針に従い削除。権限は umask を固定したケースで検査する |
| modules_test.py: module.mk 生成時に不正名・重複名を拒否して以前の一覧を保持する | 移行しない。名前・一覧の異常検出は units_spec.sh の整合性検査で確認する |
| load_test.py: 順序、定義・位置引数・IFS・オプションの保持、環境上書き、空一覧、重複、リテラルパス、特殊文字、PATH の扱い、読込失敗、実物の実行 | load_spec.sh のケースと Parameters へ展開。生成の指定は SYMBOLS/OUT に修正 |
| splice_isolated_test.py: 別シェルへの復元と置換、準備 API の非混入、漏洩、依存を除いた対照実験 | splice_isolated_spec.sh に移行。既存の準備・検証用 sh を利用する |
| split_functions_test.py: 一覧と定義の一致、全関数の単独展開、CLEANUP の保持、マクロ展開漏れ、POSIX 構文、共有名前空間、全体版との一致 | split_functions_spec.sh へ移行。全関数を動的 Parameters で列挙し、個別のケースとして報告する |
| split_globals_test.py: 一覧・初期化順、各数値派生値の独立展開、各設定の継承・空値・変更、既定値、状態の初期化、32/64/128bit 設定、リビジョン保持 | split_globals_spec.sh のケースと Parameters へ移行。128bit の算術は行わない |

旧 Python ファイルを呼ぶ ShellSpec の一括判定は、各ケースの終了状態・出力・
ファイル・値の期待値へ置き換える。実行する子シェルも `yash -efu -o posix` とし、
ライブラリを実行する正常系では `check_no_leak` を呼ぶ。

最終確認は ShellCheck、対象 spec、`make SHELL=yash test` とする。
