#!/bin/sh
. ./sx.sh

test_count=0
fail_count=0

assert() {
	test_count=$((test_count + 1))
	if eval "${1}"; then
		echo "OK: ${1}"
	else
		echo "NG: ${1}"
		eval "echo \"  Debug: a='${a-UNSET}' b='${b-UNSET}' c='${c-UNSET}' d='${d-UNSET}'\""
		fail_count=$((fail_count + 1))
	fi
}

echo "--- 1. Testing sx_var_copy ---"
a=1 b=2 c=3
sx_var_copy a b c
assert '[ "${a}" = "1" ] && [ "${b}" = "1" ] && [ "${c}" = "2" ]'

# 複数引数 (一回ずつ実行)
a=10 b=20 c=30 d=40
sx_var_copy a b
sx_var_copy c d
assert '[ "${b}" = "10" ] && [ "${d}" = "30" ]'

# 未設定の伝搬
unset a; b=99
sx_var_copy a b
assert '! sx_var_is_set b'

echo "--- 2. Testing sx_var_move ---"
a=1 b=2 c=3
sx_var_move a b c
assert '! sx_var_is_set a && [ "${b}" = "1" ] && [ "${c}" = "2" ]'

# 複数引数 (一回ずつ実行)
a=10 b=20 c=30 d=40
sx_var_move a b
sx_var_move c d
assert '! sx_var_is_set a && [ "${b}" = "10" ] && ! sx_var_is_set c && [ "${d}" = "30" ]'

echo "--- 3. Testing sx_var_swap ---"
# 2要素の入れ替え
a=1 b=2
sx_var_swap a b
assert '[ "${a}" = "2" ] && [ "${b}" = "1" ]'

# 3要素の回転 (a->b, b->c, c->a)
a=1 b=2 c=3
sx_var_swap a b c
assert '[ "${a}" = "3" ] && [ "${b}" = "1" ] && [ "${c}" = "2" ]'

# 未設定を含む回転
a=100; unset b
sx_var_swap a b
assert '! sx_var_is_set a && [ "${b}" = "100" ]'

echo "------------------------------"
if [ ${fail_count} -eq 0 ]; then
	echo "SUCCESS: All ${test_count} tests passed!"
else
	echo "FAILURE: ${fail_count} tests failed."
	exit 1
fi
