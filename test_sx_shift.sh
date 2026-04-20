#!/bin/sh
. ./sx.sh

test_copy() {
    echo "--- Testing sx_var_copy (Right Shift: v1 -> v2 -> v3) ---"
    v1=111 v2=222 v3=333
    sx_var_copy v1 v2 v3
    echo "v1=$v1 (expected: 111)"
    echo "v2=$v2 (expected: 111)"
    echo "v3=$v3 (expected: 222)"
}

test_move() {
    echo "--- Testing sx_var_move (Right Shift: v1 -> v2 -> v3, unset v1) ---"
    v1=111 v2=222 v3=333
    sx_var_move v1 v2 v3
    echo "v1=${v1-UNSET} (expected: UNSET)"
    echo "v2=$v2 (expected: 111)"
    echo "v3=$v3 (expected: 222)"
}

test_swap() {
    echo "--- Testing sx_var_swap (Right Rotation: v1->v2, v2->v3, v3->v1) ---"
    v1=111 v2=222 v3=333
    sx_var_swap v1 v2 v3
    echo "v1=$v1 (expected: 333)"
    echo "v2=$v2 (expected: 111)"
    echo "v3=$v3 (expected: 222)"
}

test_copy
test_move
test_swap
