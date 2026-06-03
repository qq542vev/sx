Describe 'sx_str_sub (callback)'
    Include ./sx.sh

    # テスト用コールバック関数
    # 数字に [ ] を付ける
    cb_bracket() {
        sx_var_set "$1=[$2]"
    }

    # 文字を大文字にする (簡易版)
    cb_upper() {
        case "$2" in
            world) sx_var_set "$1=WORLD" ;;
            *) sx_var_set "$1=$2" ;;
        esac
    }

    # 再帰的な置換を行うコールバック
    cb_recursive() {
        # マッチした文字列（例: "123"）の中の '2' を 'X' に置換する
        sx_str_sub "$1" "$2" "2" "X"
    }

    It '固定文字列マッチでコールバックを呼び出すこと'
        When call sx_str_sub res "hello world" "world" cb_upper 2147483647 "${SX_STR_SUB_CB}"
        The variable res should eq "hello WORLD"
    End

    It 'globマッチでコールバックを呼び出すこと'
        When call sx_str_sub res "a1b2c" "[0-9]" cb_bracket 2147483647 "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"
        The variable res should eq "a[1]b[2]c"
    End

    It '前方回数制限が機能すること'
        When call sx_str_sub res "a1b2c3d" "[0-9]" cb_bracket 2 "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"
        The variable res should eq "a[1]b[2]c3d"
    End

    It '後方回数制限が機能すること'
        When call sx_str_sub res "a1b2c3d" "[0-9]" cb_bracket -2 "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"
        The variable res should eq "a1b[2]c[3]d"
    End

    It '再帰呼び出しが安全に行われること'
        When call sx_str_sub res "123 222 321" "[0-9][0-9][0-9]" cb_recursive 2147483647 "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"
        The variable res should eq "1X3 XXX 3X1"
    End

    It 'コールバックが非0を返すと置換を中断すること'
        cb_stop() {
            sx_var_set "$1=X"
            return 1
        }
        When call sx_str_sub res "aaa" "a" cb_stop 2147483647 "${SX_STR_SUB_CB}"
        # 1回目は置換され(X)、そこで終了するので残りの "aa" はそのまま
        The variable res should eq "Xaa"
    End

    It '後方置換でコールバックが非0を返すと置換を中断すること'
        cb_stop() {
            sx_var_set "$1=X"
            return 1
        }
        When call sx_str_sub res "aaa" "a" cb_stop -2147483647 "${SX_STR_SUB_CB}"
        # 後方から1回目は置換され(X)、そこで終了するので残りの "aa" はそのまま
        The variable res should eq "aaX"
    End
End
