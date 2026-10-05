#!/bin/sh
# shellcheck disable=SC2016 # 圧縮対象のコードは展開せず、そのまま渡す。

eval "$(shellspec - -c) exit 1"

Describe 'awk による生成コードの圧縮'
  compact() {
    printf '%s\n' "$1" | LC_ALL=C awk -f tools/compact.awk
  }

  It 'shebangを保持し、空行・コメント・行頭空白を除去すること'
    input='#!/bin/sh

  # コメント
  a=1
  b=2'
    When run compact "$input"
    The status should be success
    The output should equal '#!/bin/sh
a=1 b=2'
  End

  It '参照を含む代入の順序を保持すること'
    input=' a=1
 b="${a}"
 :'
    When run compact "$input"
    The status should be success
    The output should equal 'a=1 b="${a}"
:'
  End

  It '空代入を結合しても値を保持し、曖昧な表記を避けること'
    input='a=
b=
c=1'
    When run compact "$input"
    The status should be success
    The output should equal "a='' b='' c=1"
  End

  It '終了ステータスとコマンド展開の代入を結合しないこと'
    input='a=$(false)
b=2
c="${?}"
d=3'
    When run compact "$input"
    The status should be success
    The output should equal "$input"
  End

  It 'コマンド付き代入や制御演算子を含む行を結合しないこと'
    input='a=1 :
b=2 && :
c=3'
    When run compact "$input"
    The status should be success
    The output should equal "$input"
  End

  It '条件付きリストの後続の代入を独立させること'
    input='false &&
a=1
b=2
!
c=3
d=4'
    When run compact "$input"
    The status should be success
    The output should equal "$input"
  End

  It '複数行文字列内の空行・コメント・空白を保持すること'
    input='a="文字列

  # 文字列の一部
  b=2
"
c=3'
    When run compact "$input"
    The status should be success
    The output should equal "$input"
  End

  It 'パラメータ展開内の引用符を追跡すること'
    input='a="${b#*"'"'"'"}"
c=1
d=2'
    When run compact "$input"
    The status should be success
    The output should equal 'a="${b#*"'"'"'"}"
c=1 d=2'
  End

  It 'バックスラッシュによる継続行を独立した代入と誤認しないこと'
    input='set -- \
  a=1 \
  b=2
c=3'
    When run compact "$input"
    The status should be success
    The output should equal "$input"
  End

  It '空行・コメントを挟むreadonlyのリテラル宣言を結合すること'
    input='readonly a=b

  # 定数宣言
  readonly z=y'
    When run compact "$input"
    The status should be success
    The output should equal 'readonly a=b z=y'
  End

  It '引用された文字列とドル単一引用符の定数を結合すること'
    input="readonly a='\$value'
readonly b=\$'\\n'
readonly c=\"text value\""
    When run compact "$input"
    The status should be success
    The output should equal "readonly a='\$value' b=\$'\\n' c=\"text value\""
  End

  It '変数参照を含むreadonly宣言を独立した行に保つこと'
    input='readonly a=1
readonly b=2
readonly c="${a}"
readonly d=3
readonly e=4'
    When run compact "$input"
    The status should be success
    The output should equal 'readonly a=1 b=2
readonly c="${a}"
readonly d=3 e=4'
  End

  It 'readonlyと通常の代入を混ぜて結合しないこと'
    input='a=1
readonly b=2
readonly c=3
d=4'
    When run compact "$input"
    The status should be success
    The output should equal 'a=1
readonly b=2 c=3
d=4'
  End

  It '条件付きreadonlyを後続の宣言と結合しないこと'
    input='false &&
readonly a=1
readonly b=2
readonly -p
readonly c=3'
    When run compact "$input"
    The status should be success
    The output should equal "$input"
  End

  It 'コマンド展開・終了ステータス・複数行のreadonly宣言を保持すること'
    input='readonly a="$(true)"
readonly b="${?}"
readonly c="文字列

  # 文字列の一部
"
readonly d=1'
    When run compact "$input"
    The status should be success
    The output should equal "$input"
  End
End
