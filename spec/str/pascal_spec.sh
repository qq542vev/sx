#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_pascal'
	Include ./sx.sh

	It 'snake_case を PascalCase に変換すること'
		When call sx_str_pascal res "hello_world"
		The variable res should equal "HelloWorld"
	End

	It 'kebab-case を PascalCase に変換すること'
		When call sx_str_pascal res "hello-world"
		The variable res should equal "HelloWorld"
	End

	It 'スペース区切りを PascalCase に変換すること'
		When call sx_str_pascal res "hello world"
		The variable res should equal "HelloWorld"
	End

	It 'camelCase を PascalCase に変換すること'
		When call sx_str_pascal res "helloWorld"
		The variable res should equal "HelloWorld"
	End

	It 'PascalCase はそのまま（冪等）'
		When call sx_str_pascal res "HelloWorld"
		The variable res should equal "HelloWorld"
	End

	It '大文字と区切り文字の混合'
		When call sx_str_pascal res "HELLO_WORLD"
		The variable res should equal "HelloWorld"
	End

	It '先頭頭字語を含む文字列'
		When call sx_str_pascal res "XMLParser"
		The variable res should equal "XmlParser"
	End

	It '末尾頭字語を含む文字列'
		When call sx_str_pascal res "parseXML"
		The variable res should equal "ParseXml"
	End

	It '単語 + 頭字語 + 単語'
		When call sx_str_pascal res "parseXMLFile"
		The variable res should equal "ParseXmlFile"
	End

	It '単一の小文字単語'
		When call sx_str_pascal res "hello"
		The variable res should equal "Hello"
	End

	It '単一の大文字単語'
		When call sx_str_pascal res "HELLO"
		The variable res should equal "Hello"
	End

	It '空文字列'
		When call sx_str_pascal res ""
		The variable res should equal ""
	End

	It '連続デリミタ'
		When call sx_str_pascal res "hello__world"
		The variable res should equal "HelloWorld"
	End

	It '先頭デリミタ'
		When call sx_str_pascal res "_hello_world"
		The variable res should equal "HelloWorld"
	End

	It 'カスタム区切り文字'
		When call sx_str_pascal res "hello/world" "/"
		The variable res should equal "HelloWorld"
	End

	It 'Readonly 変数に EX_NOPERM'
		readonly ro_var_p="const"
		When call sx_str_pascal ro_var_p "hello"
		The status should equal 77
	End

	It '無効な変数名に EX_USAGE'
		When call sx_str_pascal "1invalid" "hello"
		The status should equal 64
	End

	It 'SX_CFG_SKIP_CHK=1 で高速モード'
		SX_CFG_SKIP_CHK=1 sx_str_pascal res "helloWorld"
		The variable res should equal "HelloWorld"
	End
End
