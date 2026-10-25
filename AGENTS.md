# Project Mandates: shcore

このプロジェクトは、外部ユーティリティに一切依存せず、POSIX sh の組み込み機能のみで構成された堅牢な標準ライブラリ `sx` を構築することを目的としています。

ソースは `src/*` と `m4/common.m4` です。`sx.sh` は生成物であり、直接編集してはいけません。

---

## 1. 絶対禁止事項 (Strict Prohibitions)

- **sx.sh の直接編集禁止**: 分割ソースを編集し、`make OUT=sx.sh all` で生成してください。
- **外部ユーティリティの使用禁止**: `sx.sh` において、`[`, `test`, `echo`, `printf`, `grep`, `sed`, `awk`, `cat` 等、あらゆる外部コマンドの使用を禁止します。
  - `m4` マクロ経由で生成されるコードも同制限に従うこと。`M_*` マクロ（`M_VAR_SET`, `M_STR_*`, `M_NUM_*` 等）を使用し、`test`/`[` を回避してください。
  - 出力は変数への格納（参照渡し）を基本とし、副作用を最小限に抑えてください。
- **局所変数の直書き禁止**: 関数内の局所変数は必ず `Q_*` で記述し、`M_RENAME_Q/QI` で展開してください（§2）。`__sx_*` 形式の直書きは禁止します。

## 2. 命名規約とスコープ管理 (Naming & Scope)

POSIX sh には `local` が存在しないため、命名規則と `m4` 展開で衝突を防止します。

- **関数名**:
  - **公開 API**: `sx_<機能名>`（例: `sx_arg_find`）。引数検証のみを行い、実処理は内部関数に委譲する薄ラッパーとします。
    - `sx_var_is_name`、`sx_cfg_is_valid` など、現在は公開関数内で判定処理を直接実装している関数も、順次内部関数を作成して処理を移動します。移行前後で各 API の判定結果の終了ステータスは維持します。
  - **内部関数**: `__sx_<機能名>`（例: `__sx_arg_find`）。引数チェックを行いません。公開 API を持たない分岐ヘルパー（`_cb`/`_lit` 等、例: `__sx_arg_find_cb`）があります。
  - **ビルド時専用**（ランタイム関数ではない）: `M_*`, `__M_*`, `__sx_m4_gen_*`, `changecom`。
- **内部変数名**:
  - ソースでは必ず `Q_*`（例: `Q_arg`, `Q_bind`）で記述します。
  - ブロック全体を `M_RENAME_Q([|...|],[|基底名|])`（公開用）または `M_RENAME_QI([|...|],[|基底名|])`（内部用）で囲みます。
  - 公開用は `Q_x` → `__sx_<基底>_<x>`、内部用は `Q_x` → `__sx_<基底>_<x>_`（末尾 `_` 付き）に展開され、同名でも衝突しません。
- **ライフサイクル管理**:
  - ブロック先頭で `define([|CLEANUP|],[|Q_a Q_b|])` を宣言し、`CLEANUP` に含まれる変数が一つでも設定され得る状態での `return` 直前（早期リターン含む）に必ず `unset CLEANUP` してください。いずれにも代入していない段階での `return` では `unset` は不要です。展開後は `unset __sx_<基底>_a ...` になります。
  - `spec/spec_helper.sh` の `check_no_leak` が `__*` 変数の漏洩を自動検出します。
  - 例外: 検証のみの薄ラッパー（`Q_*` なし）は `CLEANUP` 不要。サブシェル内の裸変数（`sx_fn_is_valid` の `arg`/`body`）のみ許容します。

## 3. API 構造とエラーハンドリング (API & Errors)

- **公開関数の定型**:
  ```sh
  case "${SX_CFG_SKIP_CHK-}" in 1) __sx_xxx "${@}" || return; return;; esac
  ```
- **内部関数の契約**: ヘッダに「引数チェックは行わない」と明記します。状態管理は `set --`＋`for Q_arg in "${@}"` を優先し、結果代入は `M_VAR_SET`（`eval` による直接代入）で行います。
- **終了ステータス**:
  - `0`: 成功・一致。
  - `1` (bare): 非エラー。判定の偽・不一致・検索 0 件・bind 枯渇など。公開・内部関数の双方で、各 API の仕様に従って使用します。
  - `64` (`EX_USAGE`/`M_EX_USAGE`): 引数不正・形式不正。
  - `65` (`EX_DATAERR`/`M_EX_DATAERR`): 状態不正（対象が要求される状態にない等）。
  - `77` (`EX_NOPERM`/`M_EX_NOPERM`): 書込不可（readonly 等）。
  - `78` (`EX_CONFIG`/`M_EX_CONFIG`): 検査対象の設定値が不正または未設定。
- **関数ヘッダ**: `###` 形式で「一行概要／使い方／説明／終了ステータス」を必ず記述します。内部用は「内部実装。引数チェックは行わない。」を定型文とします。

## 4. データ構造とバインド (Data & Bind)

- **SX Array**: `変数名`（`SX_CFG_SIG_ARR` 署名＋リビジョン）、`変数名_len`、`変数名_0...` の変数セットで表現します。
  - `M_VAR_SET` は事前 unset しないため、配列が入っていた変数を結果変数に使い回す前は、必ず `sx_var_unset` を明示的に呼び出してください。
- **結果変数**: 原則として第1引数で指定（参照渡し）します。単一変数名かバインド形式かで検査を使い分けます（`sx_var_is_name`／`__sx_var_is_bind`＋`__sx_var_is_bindable` の順）。
- **バインド形式**: 蓄積前は `__sx_var_bind_init` が必須です。クォートありは `__sx_var_bind`、数値・idx 等は `__sx_var_ubind` を使用します。
- **設定とグローバル状態** (`src/var/` と `src/const/cfg/`):
  - `SX_CFG_SIG_ARR/SKIP_CHK/NUM_RANGE/SEP/ARR_UPDATE/ARR_HOLE/ARR_REF` の7変数（環境継承優先、`SX_CFG_META_DEF_*` が既定値）。署名は `SIG_ARR` で設定します。`sx_cfg_set` は引数なしで全設定を既定値に戻します。`sx_arr_push`／`sx_arr_pop`／`sx_arr_splice` と対応する通常版内部関数は、成功時に対象配列のリビジョンを必ず一度更新します。値なしの push・変更量ゼロの splice も更新し、要素不足の pop は更新しません。リビジョンを保持する場合は対応する raw 関数を使います。`sx_arr_gen` は常に更新します。`ARR_UPDATE` 設定は保持しますが、これらの更新処理は参照・検査しません。`ARR_HOLE` は疎配列の穴の表現値（既定は空文字）。`sx_arr_quote`／`sx_arr_rquote` は未設定要素を `SX_CFG_ARR_HOLE` の値で表します。
  - 設定のメタ情報は readonly の `SX_CFG_META_*` に置きます。`SX_CFG_META_NAMES` は接頭辞なしの設定項目名をスペース1文字で区切った一覧、`SX_CFG_META_DEF_*` は既定値、`SX_CFG_META_DESC_*` は短い説明、`SX_CFG_META_PATTERN_*` は受理する glob パターンを `|` で区切った列です。`META_` は設定項目名の予約接頭辞です。一覧の唯一の定義元は `M_CFG_META_NAMES` とし、検証・全リセットの引数列はビルド時に生成して `IFS` への依存を避けます。値検証の `case` は `M_CFG_META_PATTERN_*` から生成し、各選択肢に `名前=` を付けます。公開パターン列の `|` は、実行時の変数展開では選択肢の区切りとして解釈されません。
  - `sx_cfg_is_valid` の引数なし呼び出しでは全項目の現在値を検査し、未設定の項目があれば `1` を返します。設定済みの空文字とは区別します。
  - `SX_SYS_REV` は一意名・リビジョン用カウンタ（`__sx_fn_anon`、`__sx_var_touch` のみが更新）。
- **`:::` セパレータ**: `SX_CFG_SEP`（既定 `:::`）で設定引数とデータを分離します。パースは `X${SX_CFG_SEP}`＋`${N+X${N}}` イディオム（空値・`set -u` 対策）を定型とします。

## 5. 実装標準 (Implementation Standards)

- **ターゲット環境**: `yash -efu -o posix` を基準とし、最も厳格な POSIX 準拠を維持します。
- **定数体系** (`src/const/` と `m4/common.m4`): prefix で判別します。`SX_EX_*`（終了状態）、`SX_STR_*`（文字・集合・フラグ）、`SX_ARG_*`（フラグ）、`SX_NUM_*`（整数限界・`QM/ZR`・浮動小数・数学定数・基数）、`SX_CFG_META_*`（設定項目名一覧・既定値・説明・受理パターン）。m4 時定数 `M_EX_OK/USAGE/NOPERM/CONFIG` と併用します。
- **文字列操作**: `sed`/`awk` の代わりにパラメータ展開（`#`, `##`, `%`, `%%`）と `case` 文を駆使してください。
- **位置パラメータの活用**: 内部変数を増やす前に `set --` による状態管理を検討してください。
- **サブシェルの最小化**: `$(...)` や `(...)` は極限まで抑えてください。特にループ内での使用は厳禁です。
- **Bashisms 禁止**: `[[ ... ]]`, `local`, `declare`, 配列 (`var=(...)`) 等は使用禁止です。

## 6. 検証プロトコル (Validation)

- **テスト**: `shellspec`（`--warning-as-failure`、全 Example を `-efu` 下で実行＋`check_no_leak`）をパスすることを必須とします。
- **個別テスト（日常の原則）**: `make OUT=sx.sh all` と `make module` でビルド後、変更に関連する spec のみを実行します。個別生成は `make module.mk` 後に `make -f module.mk build/modules/<提供名>.sh` を使えます。テスト用の個別モジュールは既定の出力先・拡張子で生成します。既定では個別モジュールを読み込み、`SXTEST_LOAD_MOD=sx.sh` で全体版に切り替えます。`.shellspec` の警告・`spec_helper`（`-efu`＋`check_no_leak`）は個別実行時も自動継承されます。
  ```sh
  # 機能単位（公開 API と -efu 検証の両方を実行）
  make OUT=sx.sh all
  make module.mk
  make -f module.mk build/modules/sx_num_add_nat0.sh
  shellspec spec/num/add_nat0_spec.sh spec/efu/num/sx_num_add_nat0_spec.sh
  # ディレクトリ単位も可
  make module
  shellspec spec/num/
  ```
  - 読み込みは `spec_helper.sh` の `sxtest_load ./build/modules/<提供名>.sh` を使います。全体版は `SXTEST_LOAD_MOD=sx.sh shellspec ...` で指定します。事前準備・事後検証等の補助処理には `sxtest_run` を使い、テスト専用の依存を製品側へ追加しません。
  - 補助処理の詳細は [spec/support/run.md](spec/support/run.md)、読み込み指定の詳細は [spec/support/load.md](spec/support/load.md) を参照してください。個別モジュールは単独で読み込み、同じシェルで複数の機能を利用する場合は `SYMBOLS` で一つのバンドルにまとめてください。
  - 対応関係: `src/func/` の対象機能 `sx_<領域>_<機能>` は `spec/<領域>/<機能>_spec.sh` と `spec/efu/<領域>/sx_<領域>_<機能>_spec.sh` が対応します。
- **全体テスト（`make test`）**: 全単位の個別モジュールと全体版 `sx.sh` を生成し、既定の読込対象を個別モジュールとして全 spec を実行します。全体版を読み込むテストは自動実行しないため、必要な場合は別途 `SXTEST_LOAD_MOD=sx.sh shellspec ...` を実行します。`make test` は以下のいずれかに該当する場合にのみ必須とします。
  - 共通部品の変更時: `M_*` マクロ、`M_RENAME_Q/QI`、`CLEANUP` 規約、`SX_CFG_*`／`SX_SYS_REV`、`spec_helper.sh`。
  - 複数領域に跨がる変更（指定された機能の公開 API と内部関数の両方が変わる場合等）。
  - PR 提出・リリース前の最終確認。
- **テストオプション**: ShellSpec のオプションは `make test TEST_FLAGS='--jobs 4'` のように指定できます。

## 7. コミュニケーションとワークフロー (Communication & Workflow)

- **使用言語**: AI とのチャット、コード内のコメント、ドキュメント、Git のコミットメッセージは、原則として**日本語**を使用してください。
- **開発文書の管理**: 開発・ビルド手順は本書に集約します。`src/README.md` は、独立した読者・目的が明確に必要となるまで再作成しません。
- **ソースの構成と登録**: 定数・大域変数・関数は `src/const/`・`src/var/`・`src/func/` の各 `.m4` に分割し、対応する `src/const.m4`・`src/var.m4`・`src/func.m4` に `M_UNIT([|名前|], [|パス|])dnl` を一単位につき一行登録します。全体版・部分版とも定数、大域変数、関数の順に出力し、大域変数の一覧順が初期化順になります。`m4/resolve.m4` は選択と依存解決を担い、`m4/common.m4` は実行時コードを出力しません。定数の出力には `M_CONST`、シェルの引用が必要な値には `M_SH_QUOTE` を使用します。
- **依存宣言**: 各単位の先頭に `M_REQUIRE([|直接参照する実行時の名前の一覧|])dnl` を置きます。依存がない場合も `M_REQUIRE([||])dnl` を一行置き、ビルド時マクロ `M_*` は列挙しません。関数間の循環は許容し、初期化を含む循環、未知の名前、名前の重複はエラーとします。依存先は一度だけ出力します。`tools/check-units.py` は一覧と実ファイルの対応、`tools/check-dependencies.py` は依存宣言と展開後の参照を検査します。依存宣言の更新を意図する場合に限り `python3 tools/check-dependencies.py --write` を使用できます。
- **設定検査の生成**: `sx_cfg_is_valid` と `sx_cfg_set` を除く全公開関数に `M_CFG_CHECK([|公開関数名|])` を置きます。検査省略分岐がある場合はその直後、それ以外は入口とし、局所変数への代入・状態変更より前に配置します。関数自身と呼び出し先が直接参照する `SX_CFG_*` を `M_REQUIRE` から収集し、`SKIP_CHK` は除外します。`SX_SYS_*` や定数の初期化依存は設定収集では辿りません。設定の判定・設定を行う公開・内部関数は伝播の境界とします。収集時は検査マクロを無効にし、生成依存を要求設定へ戻しません。要求が空なら検査・追加依存とも生成しません。要求がある場合だけ `__sx_cfg_is_valid` と対象の設定変数を生成依存として加え、明示依存と合成して出力前に解決します。生成依存をソースの `M_REQUIRE` へ手書きしません。設定引数は `"${SX_CFG_項目+項目=${SX_CFG_項目}}"` の形でまとめて渡し、不正・未設定なら `78` を返します。空文字は項目ごとの規則で判定します。`python3 tools/check-dependencies.py --report-config` は公開関数・要求設定・到達経路をタブ区切りで出力します。通常の依存照合は、本処理の参照と明示依存、検査込みの参照と合成依存の両方を検査します。単独展開でも `m4/common.m4` が関数一覧を読み、同じ要求設定を計算します。
- **ビルドプロセス**: 全体版を `sx.sh` に保存するときは `make OUT=sx.sh all` を使用してください。`make all`（既定ターゲットの `make` も同じ）は、`OUT` が未指定または空文字列なら標準出力へ出力します（`m4` 処理後に行頭 `#` コメント行を除去。shebang は保持）。ビルド用シェルには `pipefail` 対応が必要です。既定の `/bin/sh` が未対応の場合は `make SHELL=yash OUT=sx.sh all` のように指定します。`shfmt` 等による minify は yash の算術展開の意味を変えるため禁止です。
- **ビルド選択**: make の引数 `SYMBOLS` が未指定または空文字列なら全単位、指定時はその単位と依存先を生成します。複数の単位名は `SYMBOLS="sx_uri_enc sx_uri_is_pct"` のように空白で区切ります。make の `SYMBOLS` は m4 の `SX_SYMBOLS` に渡されます。出力先は `OUT` で指定し、未指定または空文字列なら標準出力へ出力します。`all` と `bundle` は同じ生成処理を毎回実行します。`make test` は `SYMBOLS` の指定によらず全体版を `sx.sh` に生成します。
- **個別モジュール**: `make module.mk` は `find` で全単位の `.m4` を列挙し、`MOD_DIR/<提供名>MOD_EXT` の生成ルールを作成します。`MOD_DIR` の既定値は `build/modules`、`MOD_EXT` の既定値は `.sh` です。公開・内部関数、定数、大域変数をすべて対象とし、各モジュールは依存先も含めます。各ターゲットは `FORCE` に依存し、ソースが未変更でも指定されたモジュールを毎回再生成します。`make module` は一覧更新後に全件生成します。`make -f module.mk` は生成済み一覧による全件生成、ターゲット指定時は個別生成です。ソース追加・削除後は `make module.mk` または `make module` で一覧を更新してください。`module.mk` はGit管理対象外の生成物で、直接編集しません。
- **生成物のコメント方針**: `sx.sh` にコメントを含めません。仕様は `src/func/` の `###` ヘッダまたは本書を参照してください。
- **変更の適用**: `src/*` または `m4/common.m4` を編集し、ビルド（`make OUT=sx.sh all`）後に関連 spec の個別テストを実行してから進めてください。単位を追加したら対応する一覧に登録し、`tools/check-units.py` と `tools/check-dependencies.py` を実行します。全体テスト（`make test`）は §6 に該当する場合にのみ実行します。

## 8. 判断基準と記録 (Decisions & Lessons)

- **仕様優位**: 実装の挙動ではなくPOSIX 2024仕様を基準に判断します。実装差は設計根拠にしません。
- **設定変更は設定関数経由**: 派生値（`SX_SYS_*`）を持つ項目の変更は `sx_cfg_set` を使います。直接代入では派生値は更新されません。
- **能力規定**: `SX_CFG_NUM_RANGE` は実行シェルの算術域以下にします。超過時の動作は未定義です。
- **高速経路の条件**: 全算術は名前参照で行います。最小値の増分は低速経路に回します。空判定を先行します。判定条件は新しい入力のみに依存し、古い値は参照しません。
- **期待値の確定順序**: 拒否か計算かの方針を確定してからテストの期待値を書きます。
