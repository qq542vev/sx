#!/bin/sh
. ./sx.sh

# テスト: sx_var_list_set が既存の配列を正しく上書きするか
test_sx_var_list_set_cleanup() {
	echo "Testing sx_var_list_set cleanup..."
	# 既存の配列を作成
	sx_arr_gen my_res a b c
	
	# 変数一覧を取得（結果を my_res に格納）
	# my_res は既存の配列なので、__sx_var_set によって my_res_len, my_res_0 等が消えるはず
	sx_var_list_set my_res
	
	# 関連変数が消えているか確認
	if sx_var_is_set my_res_len || sx_var_is_set my_res_0; then
		echo "FAIL: my_res elements still exist"
		return 1
	fi
	
	# 結果が正しいか（my_res 自体は一覧に含まれているはず）
	if ! sx_str_has "${my_res}" "my_res"; then
		echo "FAIL: my_res not in the list"
		return 1
	fi
	
	echo "OK: sx_var_list_set cleaned up old array"
}

# 他の関数も同様にテスト（例: sx_str_sub）
test_sx_str_sub_cleanup() {
	echo "Testing sx_str_sub cleanup..."
	sx_arr_gen my_res x y z
	sx_str_sub my_res "hello world" "world" "sx"
	
	if sx_var_is_set my_res_len || sx_var_is_set my_res_0; then
		echo "FAIL: my_res elements still exist after sx_str_sub"
		return 1
	fi
	
	if ! sx_str_eq "${my_res}" "hello sx"; then
		echo "FAIL: sx_str_sub result mismatch: ${my_res}"
		return 1
	fi
	
	echo "OK: sx_str_sub cleaned up old array"
}

test_sx_var_list_set_cleanup || exit 1
test_sx_str_sub_cleanup || exit 1
echo "All cleanup tests passed."
