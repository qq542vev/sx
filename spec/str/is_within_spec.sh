#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_within / __sx_str_is_within'
	Include ./spec/support/run.sh
	sxtest_load ./build/modules/sx_str_is_within.sh

	Context '範囲判定'
		Parameters
			sx_str_is_within
			__sx_str_is_within
		End

		It 'すべての文字列が範囲内なら成功すること'
			When call "$1" 1 20 "s1" "s2" "s3"
			The status should be success
		End

		It '最小値と最大値と同じ長さの文字列も範囲内とすること'
			When call "$1" 1 3 "a" "abc" "xyz"
			The status should be success
		End

		It '文字列が1つも指定されなければ成功すること'
			When call "$1" 1 20
			The status should be success
		End

		It '最小文字数が0なら空文字列も範囲内とすること'
			When call "$1" 0 0 ""
			The status should be success
		End

		It '空文字列を下限0の範囲に含めること'
			When call "$1" 0 20 ""
			The status should be success
		End

		It '最小文字数が空なら下限を判定しないこと'
			When call "$1" "" 20 ""
			The status should be success
		End

		It '最大文字数が空なら上限を判定しないこと'
			When call "$1" 0 "" "" "abcdefghijklmnopqrstuvwxyz"
			The status should be success
		End

		It '最小文字数と最大文字数がともに空なら常に成功すること'
			When call "$1" "" "" "" "abc"
			The status should be success
		End

		It '最大文字数0なら空文字列のみを範囲内とすること'
			When call "$1" "" 0 ""
			The status should be success
		End

		It '最大文字数0で空でない文字列は失敗すること'
			When call "$1" "" 0 "a"
			The status should equal 1
		End

		It '最小文字数以上の空文字列がない場合は失敗すること'
			When call "$1" 1 "" ""
			The status should equal 1
		End

		It '文字列の長さが最小文字数未満なら失敗すること'
			When call "$1" 4 20 "abc"
			The status should equal 1
		End

		It '文字列の長さが最大文字数を超えるなら失敗すること'
			When call "$1" 1 2 "abc"
			The status should equal 1
		End

		It '複数の文字列のうち1つでも範囲外なら失敗すること'
			When call "$1" 2 3 "ab" "a" "abc"
			The status should equal 1
		End

		It '最大文字数ちょうどの文字列を範囲内とすること'
			When call "$1" 0 20 "12345678901234567890"
			The status should be success
		End

		It '最大文字数を1文字超えると失敗すること'
			When call "$1" 0 20 "123456789012345678901"
			The status should equal 1
		End

		It '最小文字数ちょうどの文字列を範囲内とすること'
			When call "$1" 20 20 "12345678901234567890"
			The status should be success
		End

		It '最小文字数を1文字下回ると失敗すること'
			When call "$1" 21 21 "12345678901234567890"
			The status should equal 1
		End

		It '最小文字数が最大文字数を超える場合は文字列がなくても失敗すること'
			When call "$1" 10 5
			The status should equal 1
		End

		It '最小文字数が最大文字数を超える場合は空文字列でも失敗すること'
			When call "$1" 10 5 ""
			The status should equal 1
		End

		It 'シェルの特殊文字も文字数として判定すること'
			When call "$1" 3 3 "*?[" "a b" ":::"
			The status should be success
		End

		It '改行を含む文字列も文字数として判定すること'
			input=$(printf 'a\nb')
			When call "$1" 3 3 "$input"
			The status should be success
		End

		It 'マルチバイト文字を現在のロケールの文字数で判定すること'
			value='日本語'
			When call "$1" "${#value}" "${#value}" "$value"
			The status should be success
		End

		It '巨大な上限値でも多倍長で判定すること'
			When call "$1" 0 999999999999999999999999999999 "abc"
			The status should be success
		End

		It '巨大な下限値を下回る文字列は失敗すること'
			When call "$1" 999999999999999999999999999999 "" "abc"
			The status should equal 1
		End

		It '巨大な最小値と最大値が等しければ文字列がなくても成功すること'
			When call "$1" 999999999999999999999999999999 999999999999999999999999999999
			The status should be success
		End

		It '巨大な最小値が最大値を超える場合は失敗すること'
			When call "$1" 999999999999999999999999999999 999999999999999999999999999998 "abc"
			The status should equal 1
		End
	End

	Context '公開関数の引数検証'
		It '引数がない場合は64を返すこと'
			When call sx_str_is_within
			The status should equal 64
		End

		It '境界引数が1つだけの場合は64を返すこと'
			When call sx_str_is_within 1
			The status should equal 64
		End

		It '最小文字数が負数の場合は64を返すこと'
			When call sx_str_is_within -1 20 "abc"
			The status should equal 64
		End

		It '最小文字数に符号が付いている場合は64を返すこと'
			When call sx_str_is_within +1 20 "abc"
			The status should equal 64
		End

		It '最小文字数に先行する0がある場合は64を返すこと'
			When call sx_str_is_within 01 20 "abc"
			The status should equal 64
		End

		It '最小文字数が小数の場合は64を返すこと'
			When call sx_str_is_within 1.5 20 "abc"
			The status should equal 64
		End

		It '最小文字数が数字以外を含む場合は64を返すこと'
			When call sx_str_is_within abc 20 "abc"
			The status should equal 64
		End

		It '最大文字数が負数の場合は64を返すこと'
			When call sx_str_is_within 1 -1 "abc"
			The status should equal 64
		End

		It '最大文字数に符号が付いている場合は64を返すこと'
			When call sx_str_is_within 1 +20 "abc"
			The status should equal 64
		End

		It '最大文字数に先行する0がある場合は64を返すこと'
			When call sx_str_is_within 1 020 "abc"
			The status should equal 64
		End

		It '最大文字数が小数の場合は64を返すこと'
			When call sx_str_is_within 1 20.5 "abc"
			The status should equal 64
		End

		It '最大文字数が数字以外を含む場合は64を返すこと'
			When call sx_str_is_within 1 abc "abc"
			The status should equal 64
		End

		It '不正な NUM_RANGE の場合は78を返すこと'
			SX_CFG_NUM_RANGE=99
			When call sx_str_is_within 1 20 "abc"
			The status should equal 78
		End

		It 'SX_CFG_SKIP_CHK=1 の場合は範囲判定のみを行うこと'
			sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' SKIP_CHK=1
			When call sx_str_is_within 1 20 "abc"
			The status should be success
		End

		It 'SX_CFG_SKIP_CHK=1 でも範囲外なら1を返すこと'
			sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' SKIP_CHK=1
			When call sx_str_is_within 10 5 "abc"
			The status should equal 1
		End
	End
End
