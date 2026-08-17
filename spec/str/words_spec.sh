#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_words'
	Include ./sx.sh

	It 'snake_case を分割すること'
		When call sx_str_words res "hello_world"
		The variable res should equal "hello world"
	End

	It 'kebab-case を分割すること'
		When call sx_str_words res "hello-world"
		The variable res should equal "hello world"
	End

	It 'camelCase を分割すること'
		When call sx_str_words res "helloWorld"
		The variable res should equal "hello world"
	End

	It 'PascalCase を分割すること'
		When call sx_str_words res "HelloWorld"
		The variable res should equal "hello world"
	End

	It '連続大文字（頭字語）を含む CamelCase'
		When call sx_str_words res "helloWorldXML"
		The variable res should equal "hello world xml"
	End

	It '頭字語 + 単語'
		When call sx_str_words res "XMLParser"
		The variable res should equal "xml parser"
	End

	It '単語 + 末尾頭字語'
		When call sx_str_words res "parseXML"
		The variable res should equal "parse xml"
	End

	It '単語 + 頭字語 + 単語'
		When call sx_str_words res "parseXMLFile"
		The variable res should equal "parse xml file"
	End

	It '全体大文字の単語'
		When call sx_str_words res "HELLO"
		The variable res should equal "hello"
	End

	It '単一の小文字単語'
		When call sx_str_words res "hello"
		The variable res should equal "hello"
	End

	It '空文字列'
		When call sx_str_words res ""
		The variable res should equal ""
	End

	It '連続デリミタ'
		When call sx_str_words res "hello__world"
		The variable res should equal "hello world"
	End

	It '先頭デリミタ'
		When call sx_str_words res "_hello_world"
		The variable res should equal "hello world"
	End

	It 'Readonly 変数に EX_NOPERM'
		readonly ro_var_w="const"
		When call sx_str_words ro_var_w "hello"
		The status should equal 77
	End

	It '無効な変数名に EX_USAGE'
		When call sx_str_words "1invalid" "hello"
		The status should equal 64
	End

	It 'SX_CFG_SKIP_CHK=1 で高速モード'
		SX_CFG_SKIP_CHK=1 sx_str_words res "helloWorld"
		The variable res should equal "hello world"
	End
End
