#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_glob_escape'
	sxtest_load ./build/modules/sx_glob_escape.sh

	Describe '正常系: 各特殊文字のエスケープ'
		It '* を [*] にエスケープする'
			When call sx_glob_escape result 'a*b'
			The variable result should equal 'a[*]b'
		End

		It '? を [?] にエスケープする'
			When call sx_glob_escape result 'a?b'
			The variable result should equal 'a[?]b'
		End

		It '[ を [[] にエスケープする'
			When call sx_glob_escape result 'a[b'
			The variable result should equal 'a[[]b'
		End

		It '] はエスケープ不要（そのまま）'
			When call sx_glob_escape result 'a]b'
			The variable result should equal 'a]b'
		End
	End

	Describe '正常系: 特殊文字を含まない文字列'
		It '英数字のみはそのまま'
			When call sx_glob_escape result 'hello'
			The variable result should equal 'hello'
		End

		It '空文字列は空のまま'
			When call sx_glob_escape result ''
			The variable result should equal ''
		End
	End

	Describe '正常系: 複合パターン'
		It '複数の特殊文字を同時にエスケープする'
			When call sx_glob_escape result '*?['
			The variable result should equal '[*][?][[]'
		End

		It '特殊文字と通常文字の混合'
			When call sx_glob_escape result 'a*b?c[d'
			The variable result should equal 'a[*]b[?]c[[]d'
		End

		It '特殊文字のみの文字列'
			When call sx_glob_escape result '***'
			The variable result should equal '[*][*][*]'
		End
	End

	Describe '正常系: case パターン内でのリテラルマッチ'
		It 'エスケープした文字列を case パターンでリテラルマッチできる'
			input='f*o' ge_p=''
			When call sx_glob_escape ge_p "$input"
			The status should be success
			The variable input should match pattern "${ge_p}"
			unset ge_p
		End

		It 'エスケープなしの glob 文字を含む文字列をリテラルマッチできる'
			input='*?[abc]' ge_p=''
			When call sx_glob_escape ge_p "$input"
			The status should be success
			The variable input should match pattern "${ge_p}"
			unset ge_p
		End

		It 'エスケープされたパターンは glob として解釈されない'
			probe='foo' ge_p=''
			When call sx_glob_escape ge_p 'f*o'
			The status should be success
			The variable probe should not match pattern "${ge_p}"
			unset ge_p
		End
	End

	Describe '異常系'
		It '読み取り専用変数に対して EX_NOPERM を返す'
			readonly MYRO_GE='const'
			When call sx_glob_escape MYRO_GE 'abc'
			The status should equal 77
		End
	End

	Describe '高速モード (SX_CFG_SKIP_CHK=1)'
		It 'チェックをバイパスして結果を返す'
			SX_CFG_SKIP_CHK=1
			When call sx_glob_escape result 'a*b?c[d'
			The variable result should equal 'a[*]b[?]c[[]d'
		End
	End
End
