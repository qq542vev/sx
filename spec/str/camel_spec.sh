#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_camel'
	Include ./sx.sh

	It 'snake_case を camelCase に変換すること'
		When call sx_str_camel res "hello_world"
		The variable res should equal "helloWorld"
	End

	It 'kebab-case を camelCase に変換すること'
		When call sx_str_camel res "hello-world"
		The variable res should equal "helloWorld"
	End

	It 'スペース区切りを camelCase に変換すること'
		When call sx_str_camel res "hello world"
		The variable res should equal "helloWorld"
	End

	It 'camelCase はそのまま（冪等）'
		When call sx_str_camel res "helloWorld"
		The variable res should equal "helloWorld"
	End

	It 'PascalCase を camelCase に変換すること'
		When call sx_str_camel res "HelloWorld"
		The variable res should equal "helloWorld"
	End

	It '大文字と区切り文字の混合'
		When call sx_str_camel res "HELLO_WORLD"
		The variable res should equal "helloWorld"
	End

	It '先頭頭字語を含む文字列'
		When call sx_str_camel res "XMLParser"
		The variable res should equal "xmlParser"
	End

	It '末尾頭字語を含む文字列'
		When call sx_str_camel res "parseXML"
		The variable res should equal "parseXml"
	End

	It '単語 + 頭字語 + 単語'
		When call sx_str_camel res "parseXMLFile"
		The variable res should equal "parseXmlFile"
	End

	It '単一の小文字単語'
		When call sx_str_camel res "hello"
		The variable res should equal "hello"
	End

	It '単一の大文字単語'
		When call sx_str_camel res "HELLO"
		The variable res should equal "hello"
	End

	It '空文字列'
		When call sx_str_camel res ""
		The variable res should equal ""
	End

	It '連続デリミタ'
		When call sx_str_camel res "hello__world"
		The variable res should equal "helloWorld"
	End

	It '先頭デリミタ'
		When call sx_str_camel res "_hello_world"
		The variable res should equal "helloWorld"
	End

	It 'カスタム区切り文字'
		When call sx_str_camel res "hello/world" "/"
		The variable res should equal "helloWorld"
	End

	It 'Readonly 変数に EX_NOPERM'
		readonly ro_var_c="const"
		When call sx_str_camel ro_var_c "hello"
		The status should equal 77
	End

	It '無効な変数名に EX_USAGE'
		When call sx_str_camel "1invalid" "hello"
		The status should equal 64
	End

	It 'SX_CFG_SKIP_CHK=1 で高速モード'
		SX_CFG_SKIP_CHK=1 sx_str_camel res "helloWorld"
		The variable res should equal "helloWorld"
	End
End
