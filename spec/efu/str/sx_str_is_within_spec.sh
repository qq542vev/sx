Describe 'sx_str_is_within / __sx_str_is_within -efu 環境検証'
	sxtest_load ./build/modules/sx_str_is_within.sh

	Context '範囲判定'
		Parameters
			sx_str_is_within
			__sx_str_is_within
		End

		It '範囲内の文字列で成功すること'
			When run efu_run "$1" 1 20 "s1" "s2" "s3"
			The status should be success
		End

		It '範囲外の文字列で1を返すこと'
			When run efu_run "$1" 1 20 ""
			The status should equal 1
		End

		It '文字列が0個なら成功すること'
			When run efu_run "$1" 1 20
			The status should be success
		End

		It '最小文字数が最大文字数を超える場合は1を返すこと'
			When run efu_run "$1" 10 5 "abc"
			The status should equal 1
		End

		It '巨大な上限値でも多倍長で判定すること'
			When run efu_run "$1" 0 999999999999999999999999999999 "abc"
			The status should be success
		End

		It 'マルチバイト文字を現在のロケールの文字数で判定すること'
			value='日本語'
			When run efu_run "$1" "${#value}" "${#value}" "$value"
			The status should be success
		End
	End

	Context '公開関数の引数検証'
		It '引数がない場合は64を返すこと'
			When run efu_run sx_str_is_within
			The status should equal 64
		End

		It '境界引数が1つだけの場合は64を返すこと'
			When run efu_run sx_str_is_within 1
			The status should equal 64
		End

		It '不正な境界値の場合は64を返すこと'
			When run efu_run sx_str_is_within -1 20 "abc"
			The status should equal 64
		End
	End
End
