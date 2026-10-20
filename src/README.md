# マクロ・定数・大域変数・関数の分割と部分版ビルド

実行時コードの定義元と通常の `make all` の入力は `sx.m4` のままです。
このディレクトリと `m4/common.m4` は、部分版を組み立てる際の入力です。
各ファイルの依存宣言はそのファイル自身で管理し、再生成しても保持します。
定義を変更した場合は、リポジトリのルートで次を実行して同期します。
再生成には Python 3.8 以降と m4 を使用します。

```sh
python3 tools/split-constants.py
python3 tools/split-constants.py --check
python3 tools/split-globals.py
python3 tools/split-globals.py --check
python3 tools/split-functions.py
python3 tools/split-functions.py --check
python3 tools/check-dependencies.py
```

```text
m4/
├── common.m4               共通マクロ・定数値マクロ・生成マクロ
└── resolve.m4              部分版の依存解決と出力
src/
├── constants.m4            元の順序で定数を列挙する一覧
├── constants/
│   ├── ex/SX_EX_*.m4       終了ステータス・名前・メッセージ
│   ├── str/SX_STR_*.m4     文字・文字集合・文字列操作フラグ
│   ├── arg/SX_ARG_*.m4     引数操作フラグ
│   ├── num/SX_NUM_*.m4     数値・桁数・QM/ZR・基数
│   └── cfg/SX_CFG_META_*.m4 設定項目一覧・既定値・説明・受理パターン
├── globals.m4              初期化順に大域変数を列挙する一覧
├── globals/
│   ├── cfg/SX_CFG_*.m4     7つの設定値を個別に初期化
│   └── sys/
│       ├── SX_SYS_REV.m4   カウンタを0で初期化
│       └── SX_SYS_NUM_*.m4 数値の派生値5つを個別に初期化
├── functions.m4            元の順序で関数を列挙する一覧
└── functions/
    ├── arg/                sx_arg_*.m4・__sx_arg_*.m4
    ├── arr/
    ├── cfg/
    ├── csv/
    ├── ex/
    ├── fn/
    ├── glob/
    ├── num/
    ├── str/
    ├── uri/
    ├── util/
    ├── uuid/
    └── var/
```

共通マクロを先に一度読み込み、必要な定数ファイルを指定します。
パスはリポジトリのルートを基準にしています。
各一覧の `M_UNIT([|名前|], [|パス|])` は、通常の全体展開では `include` と同じです。
部分版では名前とパスの対応、および元の出力順の両方に使用します。

```sh
# 公開 API 一つと、その間接依存を含む部分版を作る。
make SX_SYMBOLS=sx_uri_enc SX_OUT=build/sx-uri-enc.sh bundle

# 複数の名前を選ぶ。SX_OUT の省略時は sx-bundle.sh に出力する。
make SX_SYMBOLS='sx_uri_enc sx_uri_is_pct' bundle
```

`SX_SYMBOLS` は空白1文字で区切る名前の一覧です。依存は各ファイルの `M_REQUIRE` を再帰的にたどります。
探索中は出力を破棄し、読み込み前に訪問済みを記録して循環と重複を止めます。
次に一覧を定数→大域変数→関数の順で読み直し、選択済みだけを出力します。
関数間の循環は許し、初期化を含む循環はエラーにします。未知の名前、書式不正、一覧内の提供名重複もエラーです。
`bundle` は毎回生成するため、同じ `SX_OUT` に別の名前を指定しても古い定義は残りません。
依存解決には Python を使用しません。出力のコメント除去には通常ビルドと同じ `awk` を使用します。

```sh
# 一つの定数だけを展開する。
m4 -- m4/common.m4 src/constants/cfg/SX_CFG_META_PATTERN_NUM_RANGE.m4

# 全定数を展開する。
m4 -- m4/common.m4 src/constants.m4
```

各定数ファイルは一つの `readonly` 宣言だけを出力します。
ファイル内には依存宣言と、接頭辞を除いた定数名を渡す `M_CONST` 呼び出しを記述します。

```m4
M_REQUIRE([||])dnl
M_CONST([|STR_ALNUM|])
```

この呼び出しは `M_STR_ALNUM` の値から `readonly SX_STR_ALNUM=...` を生成します。
Portable Filename Character Set（英数字と `._-`）だけを含む非空の値は引用を省略し、それ以外は `M_SH_QUOTE` で引用します。
固定値と合成は共通マクロで管理し、値を重複定義しません。
文字列の引用には `M_SH_QUOTE` を使用します。
単一引用符の連続部分は引用の外でエスケープし、それ以外はバックスラッシュや制御文字もそのまま保持します。
LF を含む定数の宣言は複数行になります。
`QM`・`ZR` の各桁の値は共通ファイルでマクロとして生成し、実行時定数の出力は個別に行います。
`SX_CFG_META_PATTERN_*` もほかの定数と同じ `M_CONST` 呼び出しで個別に展開します。
共通ファイル自体は実行時コードを出力しません。

各単位の `M_REQUIRE([|...|])dnl` には、直接参照する実行時の関数・定数・大域変数の名前を空白区切りで列挙します。依存がない場合も空の宣言を一つ置きます。`M_*` と `__sx_m4_gen_*` は共通ファイルのビルド時マクロなので列挙しません。例えば `__sx_uri_enc` は `SX_STR_ALNUM __sx_var_bind_init __sx_var_ubind`、`sx_uri_enc` は `SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_uri_enc __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid` を宣言します。
全単位が1ファイルで1名を定義するため、提供名はファイル名から決まります。`M_REQUIRE` は実行時コードを出力しません。
`tools/check-dependencies.py` は m4 展開後の参照と宣言を照合します。名前を組み立てる数値関数呼び出しは `arith` と `nat0` の両候補、数値範囲に応じた定数参照は32・64・128の全候補を含めます。宣言を意図的に更新するときだけ `python3 tools/check-dependencies.py --write` を実行します。

大域変数は13変数を13ファイルに分割します。`globals.m4` は各ファイルを元の順序で一度ずつ読み込みます。
設定項目の名前と順序は元ソースの `M_CFG_META_NAMES` と照合し、欠落・重複・未対応の初期化式はエラーにします。
古い大域変数ファイルが残っている場合もエラーとし、自動削除しません。

設定値は `${SX_CFG_項目-${SX_CFG_META_DEF_項目}}` の式を保持し、未設定の場合だけ既定値を使います。
設定済みの空文字は保持します。大域変数は変更可能なため `M_CONST` は使いません。
`SX_SYS_REV` は既存値にかかわらず0に戻し、数値の派生値は `SX_CFG_NUM_RANGE` から求め直します。
`SX_SYS_NUM_WLEN/QM/ZR/MAX/MIN` はそれぞれのファイルで対応する定数を参照し、一つずつ `eval` で初期化します。
出力の圧縮時にこれらの代入をまとめることはできますが、分割単位は変えません。

初期化順は「共通マクロ → 定数 → 大域変数 → 関数」です。
各設定値は対応する `SX_CFG_META_DEF_*`、数値の派生値は `SX_CFG_NUM_RANGE` と `SX_NUM_I32/I64/I128_*` に依存します。
設定は実行時に変更できるため、数値範囲の依存を既定値だけに絞りません。
初期化では関数を呼び出さず、実行中の設定変更と派生値更新は引き続き `sx_cfg_set` が担当します。

```sh
# 必要な既定値定数と一つの設定値だけを展開する。
m4 -- m4/common.m4 src/constants/cfg/SX_CFG_META_DEF_NUM_RANGE.m4 src/globals/cfg/SX_CFG_NUM_RANGE.m4

# 全定数と全大域変数の初期化コードを展開する。
m4 -- m4/common.m4 src/constants.m4 src/globals.m4
```

`spec/build/split_globals_spec.sh` は設定値・数値派生値の単独展開、環境値・空文字の保持、既定値、
32・64・128に対応する派生元の参照、カウンタの初期化、設定変更後の更新を検証します。
数値範囲128の検証では128bitの算術を行いません。

関数は公開・内部・コールバック用ヘルパーをそれぞれ1ファイルに分割します。
動的に定義される関数は、定義処理を行う関数の本体に残します。
各ファイルには `###` ヘッダ、関数定義、元の `M_RENAME_Q/QI` の種類と基底名を保持します。
`CLEANUP` は関数ブロックに置き、各ファイルの `pushdef`・`popdef` で外側のマクロ定義を保存・復元します。

`__sx_str_escape_cb` は `str_escape`、`__sx_str_sub_isep_adapt` は `str_sub` の基底名を使います。
これらは親関数の作業変数を共有するため、ファイル名から基底名を変更しません。
変数の後始末も元の所有関係を維持します。
URI エンコードの分岐生成マクロは共通ファイルの定義を使い、関数ファイル内では再定義・削除しません。

```sh
# 一つの関数ファイルだけを展開する。依存付きの部分版には make bundle を使用する。
m4 -- m4/common.m4 src/functions/str/__sx_str_escape_cb.m4

# 全関数の定義を展開する。
m4 -- m4/common.m4 src/functions.m4

# 分割した定数・大域変数・関数を組み合わせて通常ビルドと比較する。
python3 tools/split-functions.py --assemble > /tmp/sx-split.m4
m4 -- /tmp/sx-split.m4 > /tmp/sx-split.raw
LC_ALL=C awk -f tools/compact.awk /tmp/sx-split.raw > /tmp/sx-split.sh
cmp sx.sh /tmp/sx-split.sh
```

生成処理は `sx.m4` の「関数定義」コメント以降を対象とします。
m4 の入れ子の引用を追跡し、関数ヘッダを境界に分割します。
関数ヘッダと定義の不一致、重複、未対応の前後処理、名前変換ブロックの不正などはエラーにします。
`--check` は同期の検査だけを行い、`--assemble` は比較用の m4 入力だけを出力します。
元の定義にない古い関数ファイルがあれば、生成・同期検査ともにエラーとし、自動削除しません。

`spec/build/split_functions_spec.sh` は全関数の単独展開・構文・マクロのスコープと、
通常ビルドとのバイト単位の一致を検証します。検証には yash も使用します。
大域変数・関数の本体は `sx.m4` から再生成し、依存宣言だけを分割ファイルで編集します。
`spec/build/bundle_spec.sh` は単独・複数選択、循環、重複、不正な指定、数値範囲、全体版との一致を検証します。
