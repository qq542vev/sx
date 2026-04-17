. ./sx.sh

# 1. 配列名のみ（現在の長さまでチェック）
echo "Testing sx_arr_is_rw (name only)..."
arr_len=2
arr_0=val0
arr_1=val1
if sx_arr_is_rw arr; then
    echo "  arr (len=2): OK"
else
    echo "  arr (len=2): FAILED"
fi

readonly arr_1=ro
if ! sx_arr_is_rw arr; then
    echo "  arr (readonly detect): OK"
else
    echo "  arr (readonly detect): FAILED"
fi

# 2. 複数範囲指定 (開始, 個数)
echo "Testing sx_arr_is_rw (multiple ranges)..."
# テスト用に別の名前を使用
arr2_len=10
# 0から6要素(0-5), 8から3要素(8-10)
if sx_arr_is_rw arr2 0 6 8 3; then
    echo "  arr2 (0-5 and 8-10): OK"
else
    echo "  arr2 (0-5 and 8-10): FAILED"
fi

# 3. sx_arr_push
echo "Testing sx_arr_push..."
unset p_arr_len p_arr_0
sx_arr_push p_arr "val"
if [ "${p_arr_len}" = "1" ] && [ "${p_arr_0}" = "val" ]; then
    echo "  sx_arr_push: OK"
else
    echo "  sx_arr_push: FAILED"
fi

# 4. 個数省略のテスト
echo "Testing sx_arr_is_rw (count omitted)..."
arr3_len=5
if sx_arr_is_rw arr3 2; then
    echo "  arr3 (2 to end): OK"
else
    echo "  arr3 (2 to end): FAILED"
fi
