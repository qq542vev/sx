#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_glob_safe'
	Include ./sx.sh

	Describe '正常系: 通常の文字セット'
		It '1文字のセットをブラケット式に変換する'
			When call sx_str_glob_safe result 'a'
			The variable result should equal '[a]'
		End

		It '複数文字のセットをブラケット式に変換する'
			When call sx_str_glob_safe result 'abc'
			The variable result should equal '[abc]'
		End

		It '英数字混合のセットをブラケット式に変換する'
			When call sx_str_glob_safe result 'abc123'
			The variable result should equal '[abc123]'
		End

		It '結果変数に正しく代入される'
			When call sx_str_glob_safe result 'xyz'
			The variable result should equal '[xyz]'
		End
	End

	Describe '正常系: ] の処理（先頭配置）'
		It '] 単体を処理する'
			When call sx_str_glob_safe result ']'
			The variable result should equal '[]]'
		End

		It '] が先頭に配置される（後続の文字はそのまま）'
			When call sx_str_glob_safe result ']a'
			The variable result should equal '[]a]'
		End

		It '] が中間にある場合も先頭に移動される'
			When call sx_str_glob_safe result 'a]b'
			The variable result should equal '[]ab]'
		End

		It '] と ! を同時に処理する'
			When call sx_str_glob_safe result ']!abc'
			The variable result should equal '[]abc!]'
		End

		It '] と - を同時に処理する'
			When call sx_str_glob_safe result ']abc-'
			The variable result should equal '[]abc-]'
		End
	End

	Describe '正常系: - の処理（末尾配置）'
		It '- 単体を処理する'
			When call sx_str_glob_safe result '-'
			The variable result should equal '[-]'
		End

		It '- が末尾に配置される'
			When call sx_str_glob_safe result 'a-'
			The variable result should equal '[a-]'
		End

		It '- が先頭にある場合も末尾に移動される'
			When call sx_str_glob_safe result '-a'
			The variable result should equal '[a-]'
		End

		It '- が中間にある場合も末尾に移動される（範囲式の防止）'
			When call sx_str_glob_safe result 'a-b'
			The variable result should equal '[ab-]'
		End

		It '複数の - は1つだけ末尾に配置される'
			When call sx_str_glob_safe result 'a--b'
			The variable result should equal '[ab-]'
		End
	End

	Describe '正常系: ! の処理（末尾配置）'
		It '! 単体はブラケット式にせずそのまま返す'
			When call sx_str_glob_safe result '!'
			The variable result should equal '!'
		End

		It '複数の ! のみもそのまま返す'
			When call sx_str_glob_safe result '!!'
			The variable result should equal '!'
		End

		It '! が先頭にある場合は末尾に移動される'
			When call sx_str_glob_safe result '!a'
			The variable result should equal '[a!]'
		End

		It '! が中間にある場合は末尾に移動される'
			When call sx_str_glob_safe result 'a!b'
			The variable result should equal '[ab!]'
		End

		It '! が複数あっても1つだけ末尾に追加される'
			When call sx_str_glob_safe result '!abc!'
			The variable result should equal '[abc!]'
		End

		It '! と ] を同時に処理する'
			When call sx_str_glob_safe result ']!'
			The variable result should equal '[]!]'
		End
	End

	Describe '正常系: ^ の処理（末尾配置／否定防止）'
		It '^ 単体を処理する'
			When call sx_str_glob_safe result '^'
			The variable result should equal '^'
		End

		It '^ が先頭にある場合は末尾に移動される'
			When call sx_str_glob_safe result '^a'
			The variable result should equal '[a^]'
		End

		It '^ が中間にある場合は末尾に移動される'
			When call sx_str_glob_safe result 'a^b'
			The variable result should equal '[ab^]'
		End

		It '^ が複数あっても1つだけ末尾に追加される'
			When call sx_str_glob_safe result '^^a'
			The variable result should equal '[a^]'
		End

		It '^ と ] を同時に処理する'
			When call sx_str_glob_safe result ']^a'
			The variable result should equal '[]a^]'
		End

		It '^ と ! を同時に処理する（両方末尾へ）'
			When call sx_str_glob_safe result '^!a'
			The variable result should equal '[a!^]'
		End

		It '^ と - を同時に処理する'
			When call sx_str_glob_safe result '^-'
			The variable result should equal '[-^]'
		End

		It '! と ^ のみのセットを collating symbol で処理する'
			When call sx_str_glob_safe result '!^'
			The variable result should equal '[[.!.]^]'
		End

		It '! と ^ と - のセットをケースハンドラで安全な形に変換する'
			When call sx_str_glob_safe result '!^-'
			The variable result should equal '[-!^]'
		End

		It '^ と ! と - のセット（順序逆）も同様に処理する'
			When call sx_str_glob_safe result '^!-'
			The variable result should equal '[-!^]'
		End
	End

	Describe '正常系: = の処理（末尾配置／等価クラス防止）'
		It '= 単体を処理する'
			When call sx_str_glob_safe result '='
			The variable result should equal '[=]'
		End

		It '=a= の先頭 = を末尾に移動する（等価クラス式 [=a=] の防止）'
			When call sx_str_glob_safe result '=a='
			The variable result should equal '[a=]'
		End

		It '==a の先頭 = を末尾に移動する'
			When call sx_str_glob_safe result '==a'
			The variable result should equal '[a=]'
		End

		It '=== は [=] になる（縮退ケース、1要素で安全）'
			When call sx_str_glob_safe result '==='
			The variable result should equal '[=]'
		End

		It '=! を処理する（2要素で安全）'
			When call sx_str_glob_safe result '=!'
			The variable result should equal '[=!]'
		End
	End

	Describe '正常系: . の処理（末尾配置／照合記号防止）'
		It '. 単体を処理する'
			When call sx_str_glob_safe result '.'
			The variable result should equal '[.]'
		End

		It '.a. の先頭 . を末尾に移動する（照合記号 [.a.] の防止）'
			When call sx_str_glob_safe result '.a.'
			The variable result should equal '[a.]'
		End

		It '..a の先頭 . を末尾に移動する'
			When call sx_str_glob_safe result '..a'
			The variable result should equal '[a.]'
		End

		It '... は [.] になる（縮退ケース、1要素で安全）'
			When call sx_str_glob_safe result '...'
			The variable result should equal '[.]'
		End

		It 'a.b の . を末尾に移動する'
			When call sx_str_glob_safe result 'a.b'
			The variable result should equal '[ab.]'
		End
	End

	Describe '正常系: : の処理（末尾配置／文字クラス防止）'
		It ': 単体を処理する'
			When call sx_str_glob_safe result ':'
			The variable result should equal '[:]'
		End

		It ':a: の先頭 : を末尾に移動する（文字クラス [:a:] の防止）'
			When call sx_str_glob_safe result ':a:'
			The variable result should equal '[a:]'
		End

		It '::a の先頭 : を末尾に移動する'
			When call sx_str_glob_safe result '::a'
			The variable result should equal '[a:]'
		End

		It '::: は [:] になる（縮退ケース、1要素で安全）'
			When call sx_str_glob_safe result ':::'
			The variable result should equal '[:]'
		End
	End

	Describe '正常系: 特殊文字の複合'
		It '全ての特殊文字を同時に処理する（] ! - = . :）'
			When call sx_str_glob_safe result ']!abc-=.:'
			The variable result should equal '[]abc=.:!-]'
		End

		It '[ はブラケット式内でリテラルとして扱われる'
			When call sx_str_glob_safe result ']x['
			The variable result should equal '[]x[]'
		End

		It '[: が先頭以外にあればリテラル'
			When call sx_str_glob_safe result ']x[:'
			The variable result should equal '[]x[:]'
		End

		It '英数字との混合（!abc123）'
			When call sx_str_glob_safe result '!abc123'
			The variable result should equal '[abc123!]'
		End

		It '英数字との混合（=abc123）'
			When call sx_str_glob_safe result '=abc123'
			The variable result should equal '[abc123=]'
		End

		It '英数字との混合（.abc123）'
			When call sx_str_glob_safe result '.abc123'
			The variable result should equal '[abc123.]'
		End

		It '英数字との混合（:abc123）'
			When call sx_str_glob_safe result ':abc123'
			The variable result should equal '[abc123:]'
		End

		It 'すべての特殊文字を含む複合パターン'
			When call sx_str_glob_safe result ']x!=.:y-'
			The variable result should equal '[]xy=.:!-]'
		End
	End

	Describe '正常系: POSIX 未規定パターンの防止'
		It '[=a=] パターンを防止する（先頭=末尾が=の3要素→未規定）'
			When call sx_str_glob_safe result '=a='
			The variable result should equal '[a=]'
		End

		It '[.a.] パターンを防止する（先頭=末尾が.の3要素→未規定）'
			When call sx_str_glob_safe result '.a.'
			The variable result should equal '[a.]'
		End

		It '[:a:] パターンを防止する（先頭=末尾が:の3要素→未規定）'
			When call sx_str_glob_safe result ':a:'
			The variable result should equal '[a:]'
		End

		It '=== は1要素になり未規定を回避する'
			When call sx_str_glob_safe result '==='
			The variable result should equal '[=]'
		End

		It '] が先頭にあれば = は位置0ではなく安全'
			When call sx_str_glob_safe result ']=a='
			The variable result should equal '[]a=]'
		End

		It '] が先頭にあれば . は位置0ではなく安全'
			When call sx_str_glob_safe result '].a.'
			The variable result should equal '[]a.]'
		End

		It '] が先頭にあれば : は位置0ではなく安全'
			When call sx_str_glob_safe result ']:a:'
			The variable result should equal '[]a:]'
		End
	End

	Describe '正常系: \ の処理（エスケープ防止）'
		It '\ 単体を処理する'
			When call sx_str_glob_safe result '\'
			The variable result should equal '[\\]'
		End

		It '\ を末尾に配置する（\ が ] をエスケープするのを防止）'
			When call sx_str_glob_safe result 'a\b'
			The variable result should equal '[ab\\]'
		End

		It '] と \ と - を同時に処理する'
			When call sx_str_glob_safe result '\]-'
			The variable result should equal '[]\\-]'
		End

		It '全特殊文字と \ を同時に処理する'
			When call sx_str_glob_safe result '\=.:!-'
			The variable result should equal '[\\=.:!-]'
		End

		It '複数の \ は1つだけ \\ に変換される'
			When call sx_str_glob_safe result '\\'
			The variable result should equal '[\\]'
		End

		It '通常文字と \ の混合'
			When call sx_str_glob_safe result 'a\b\c'
			The variable result should equal '[abc\\]'
		End
	End

	Describe '異常系'
		It '読み取り専用変数に対して EX_NOPERM を返す'
			readonly MYRO_GS='const'
			When call sx_str_glob_safe MYRO_GS 'a'
			The status should equal "${SX_EX_NOPERM}"
		End
	End

	Describe '高速モード (SX_CFG_SKIP_CHK=1)'
		It 'チェックをバイパスして結果を返す'
			SX_CFG_SKIP_CHK=1
			When call sx_str_glob_safe result 'abc'
			The variable result should equal '[abc]'
		End
	End
End
