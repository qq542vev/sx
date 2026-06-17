#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_find'
	Include ./sx.sh

	It '単一一致で index:len を返すこと'
		When call sx_str_find res "hello world" "world"
		The status should be success
		The variable res should equal "6:5"
	End

	It '複数一致をスペース区切りで返すこと'
		When call sx_str_find res "ab_cd_ef" "_"
		The status should be success
		The variable res should equal "2:1 5:1"
	End

	It '重複なしかつ隣接一致を正しく検出すること'
		When call sx_str_find res "a__bc" "__"
		The status should be success
		The variable res should equal "1:2"
	End

	It '空 needle は全境界位置（末尾含む）に長さ0で出力すること'
		When call sx_str_find res "abc" ""
		The status should be success
		The variable res should equal "0:0 1:0 2:0 3:0"
	End

	It '空文字列に空 needle で位置0を返すこと'
		When call sx_str_find res "" ""
		The status should be success
		The variable res should equal "0:0"
	End

	It '空文字列に非空 needle で不一致を返すこと'
		When call sx_str_find res "" "a"
		The status should be failure
		The variable res should equal ""
	End

	It '不一致で空文字列・終了ステータス1を返すこと'
		When call sx_str_find res "abc" "x"
		The status should be failure
		The variable res should equal ""
	End

	It 'バインド形式 Nname: で最大件数を指定できること'
		sx_str_find "2res:" "a_b_c_d" "_"
		Assert [ "$res" = "1:1 3:1" ]
	End

	It 'バインド形式 name:name で分配できること'
		sx_str_find "fst:snd" "a_b_c" "_"
		Assert [ "$fst" = "1:1" ]
		Assert [ "$snd" = "3:1" ]
	End

	It 'バインド形式で超過分は無視されること'
		sx_str_find "1pos:" "a_b" "_"
		Assert [ "$pos" = "1:1" ]
	End

	It '無効な変数名でエラーになること'
		When call sx_str_find "1invalid" "abc" "a"
		The status should eq "$SX_EX_USAGE"
	End

	It '読み取り専用変数でエラーになること'
		readonly ro_var=0
		When call sx_str_find ro_var "abc" "a"
		The status should eq "$SX_EX_NOPERM"
	End

	It '重複フラグ有効で重なり合う一致をすべて見つけること'
		When call sx_str_find res "aaa" "aa" "$SX_STR_FIND_OVERLAP"
		The status should be success
		The variable res should equal "0:2 1:2"
	End

	It '重複フラグ無効で従来の動作を維持すること'
		When call sx_str_find res "aaa" "aa" 0
		The status should be success
		The variable res should equal "0:2"
	End

	It '重複フラグ有効で複数重複一致を検出すること'
		When call sx_str_find res "ababa" "aba" "$SX_STR_FIND_OVERLAP"
		The status should be success
		The variable res should equal "0:3 2:3"
	End

	It '重複フラグ有効で通常の一致も正しく動作すること'
		When call sx_str_find res "ab_cd_ef" "_" "$SX_STR_FIND_OVERLAP"
		The status should be success
		The variable res should equal "2:1 5:1"
	End

	It '重複フラグ有効で不一致は空文字列を返すこと'
		When call sx_str_find res "abc" "x" "$SX_STR_FIND_OVERLAP"
		The status should be failure
		The variable res should equal ""
	End

	It '重複フラグ有効で空needleは全境界位置を返すこと'
		When call sx_str_find res "abc" "" "$SX_STR_FIND_OVERLAP"
		The status should be success
		The variable res should equal "0:0 1:0 2:0 3:0"
	End

	It 'globモードでワイルドカード * が機能すること'
		When call sx_str_find res "hello world" "w*" "$SX_STR_FIND_GLOB"
		The status should be success
		The variable res should equal "6:1"
	End

	It 'globモードで ? が機能すること'
		When call sx_str_find res "abc" "?b" "$SX_STR_FIND_GLOB"
		The status should be success
		The variable res should equal "0:2"
	End

	It 'globモードで文字クラス [...] が機能すること'
		When call sx_str_find res "abcd" "[ab]b" "$SX_STR_FIND_GLOB"
		The status should be success
		The variable res should equal "0:2"
	End

	It 'globモードで不一致は空文字列を返すこと'
		When call sx_str_find res "abc" "x*" "$SX_STR_FIND_GLOB"
		The status should be failure
		The variable res should equal ""
	End

	It 'globモードで空文字列に非空パターンで不一致を返すこと'
		When call sx_str_find res "" "a*" "$SX_STR_FIND_GLOB"
		The status should be failure
		The variable res should equal ""
	End

	It 'globモードで空needleは全境界位置を返すこと'
		When call sx_str_find res "ab" "" "$SX_STR_FIND_GLOB"
		The status should be success
		The variable res should equal "0:0 1:0 2:0"
	End

	It 'globモードで複数一致を返すこと'
		When call sx_str_find res "aXbXc" "X*" "$SX_STR_FIND_GLOB"
		The status should be success
		The variable res should equal "1:1 3:1"
	End

	It 'globモードで重複フラグと組み合わせられること'
		When call sx_str_find res "aaa" "a*" "$(($SX_STR_FIND_GLOB | $SX_STR_FIND_OVERLAP))"
		The status should be success
		The variable res should equal "0:1 1:1 2:1"
	End

	It 'globモードでバインド形式 Nname: が機能すること'
		sx_str_find "2res:" "a_b_c" "?b" "$SX_STR_FIND_GLOB"
		Assert [ "$res" = "1:2" ]
	End

	It 'globモードで文字クラス範囲 [a-z] が機能すること'
		When call sx_str_find res "abc123" "[a-z]" "$SX_STR_FIND_GLOB"
		The status should be success
		The variable res should equal "0:1 1:1 2:1"
	End

	It 'globモードで否定文字クラス [!abc] が機能すること'
		When call sx_str_find res "abc123" "[!abc]" "$SX_STR_FIND_GLOB"
		The status should be success
		The variable res should equal "3:1 4:1 5:1"
	End

	It 'globモードで ? 単体が全文字に一致すること'
		When call sx_str_find res "abc" "?" "$SX_STR_FIND_GLOB"
		The status should be success
		The variable res should equal "0:1 1:1 2:1"
	End

	It 'globモードでワイルドカードとリテラルの複合パターンが機能すること'
		When call sx_str_find res "hello.txt" "*.txt" "$SX_STR_FIND_GLOB"
		The status should be success
		The variable res should equal "0:9"
	End

	It 'globモードでバインド形式 name:name が機能すること'
		sx_str_find "fst:snd" "a_b_c" "?b" "$SX_STR_FIND_GLOB"
		Assert [ "$fst" = "1:2" ]
	End

	It 'globモードで * 単体が空needle相当になること'
		When call sx_str_find res "abc" "*" "$SX_STR_FIND_GLOB"
		The status should be success
		The variable res should equal "0:0 1:0 2:0 3:0"
	End

	It 'globモードで * 単体と重複フラグを組み合わせられること'
		When call sx_str_find res "abc" "*" "$(($SX_STR_FIND_GLOB | $SX_STR_FIND_OVERLAP))"
		The status should be success
		The variable res should equal "0:0 1:0 2:0 3:0"
	End

	It 'globモードで * 単体が空文字列に境界位置を返すこと'
		When call sx_str_find res "" "*" "$SX_STR_FIND_GLOB"
		The status should be success
		The variable res should equal "0:0"
	End

	It 'TEXTモードで単一一致の文字列を分配できること'
		sx_str_find "fst:" "hello world" "world" "$SX_STR_FIND_TEXT"
		Assert [ "$fst" = "world" ]
	End

	It 'TEXTモードで複数一致を分配できること'
		sx_str_find "fst:snd:" "a_b_c" "_" "$SX_STR_FIND_TEXT"
		Assert [ "$fst" = "_" ]
		Assert [ "$snd" = "_" ]
	End

	It 'TEXTモードで全件（res）にクォート付きで格納されること'
		When call sx_str_find res "abc" "b" "$SX_STR_FIND_TEXT"
		The status should be success
		The variable res should equal "'b'"
	End

	It 'TEXTモードで不一致は終了ステータス1を返すこと'
		When call sx_str_find res "abc" "x" "$SX_STR_FIND_TEXT"
		The status should be failure
		The variable res should equal ""
	End

	It 'TEXTモードでカウント付き分配にクォート付きで格納されること'
		sx_str_find "2fst:" "a_b_c" "_" "$SX_STR_FIND_TEXT"
		Assert [ "$fst" = "'_' '_'" ]
	End

	It 'TEXT+globモードで ?b パターンのマッチ文字列を分配できること'
		sx_str_find "fst:" "abc" "?b" "$(($SX_STR_FIND_GLOB | $SX_STR_FIND_TEXT))"
		Assert [ "$fst" = "ab" ]
	End

	It 'TEXT+globモードで * パターンの複数一致を分配できること'
		sx_str_find "fst:snd:" "aXbXc" "X*" "$(($SX_STR_FIND_GLOB | $SX_STR_FIND_TEXT))"
		Assert [ "$fst" = "X" ]
		Assert [ "$snd" = "X" ]
	End

	It 'TEXT+globモードで不一致は終了ステータス1を返すこと'
		When call sx_str_find res "abc" "x*" "$(($SX_STR_FIND_GLOB | $SX_STR_FIND_TEXT))"
		The status should be failure
	End

	It 'TEXT+globモードで ? 単体が全文字を返すこと'
		sx_str_find "3fst:" "abc" "?" "$(($SX_STR_FIND_GLOB | $SX_STR_FIND_TEXT))"
		Assert [ "$fst" = "'a' 'b' 'c'" ]
	End

	It 'TEXT+overlapモードで重複一致の文字列を返すこと'
		sx_str_find "2fst:" "aaa" "aa" "$(($SX_STR_FIND_OVERLAP | $SX_STR_FIND_TEXT))"
		Assert [ "$fst" = "'aa' 'aa'" ]
	End

	It 'TEXTモード（非overlap）で重複しない一致のみ返すこと'
		sx_str_find "fst:" "aaa" "aa" "$SX_STR_FIND_TEXT"
		Assert [ "$fst" = "aa" ]
	End

	It 'TEXT+glob+overlapモードで全フラグを組み合わせられること'
		sx_str_find "3fst:" "aaa" "a*" "$(($SX_STR_FIND_GLOB | $SX_STR_FIND_OVERLAP | $SX_STR_FIND_TEXT))"
		Assert [ "$fst" = "'a' 'a' 'a'" ]
	End
End
