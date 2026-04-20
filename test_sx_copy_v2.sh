#!/bin/sh
. ./sx.sh

# テスト結果の集計用
errors=0
test_count=0

assert_val() {
    test_count=$((test_count + 1))
    name=$1; actual=$2; expected=$3; msg=$4
    if [ "${actual}" = "${expected}" ]; then
        echo "  [OK] ${msg}: ${name}='${actual}'"
    else
        echo "  [FAIL] ${msg}: ${name}='${actual}' (expected: '${expected}')"
        errors=$((errors + 1))
    fi
}

echo "=== Comprehensive Test for sx_var_copy (Right Shift) ==="

# 1. 基本的な連鎖コピー (v1 -> v2 -> v3)
v1=AAA v2=BBB v3=CCC
sx_var_copy v1 v2 v3
assert_val "v1" "$v1" "AAA" "Source remains unchanged"
assert_val "v2" "$v2" "AAA" "v1 copied to v2"
assert_val "v3" "$v3" "BBB" "v2 original copied to v3"

# 2. 未設定変数が含まれる場合
unset u1 u2
u0=START
sx_var_copy u0 u1 u2
assert_val "u1" "$u1" "START" "u0 copied to u1"
if ! sx_var_is_set u2; then
    echo "  [OK] u2 is UNSET as expected"
else
    echo "  [FAIL] u2 should be UNSET (copied from unset u1)"
    errors=$((errors + 1))
fi

# 3. 複数の連鎖を個別に実行
a1=1 a2=2 b1=10 b2=20
sx_var_copy a1 a2
sx_var_copy b1 b2
assert_val "a2" "$a2" "1" "Multiple chain 1"
assert_val "b2" "$b2" "10" "Multiple chain 2"

# 4. 読み取り専用エラーのチェック
readonly r1=READONLY
sx_var_copy a1 r1 2>/dev/null
if [ $? -eq 77 ]; then
    echo "  [OK] Readonly destination correctly blocked (SX_EX_NOPERM)"
else
    echo "  [FAIL] sx_var_copy should return 77 (SX_EX_NOPERM) for readonly destination, got $?"
    errors=$((errors + 1))
fi

echo ""
if [ $errors -eq 0 ]; then
    echo "RESULT: ALL ${test_count} TESTS PASSED!"
else
    echo "RESULT: ${errors} / ${test_count} TESTS FAILED."
fi
