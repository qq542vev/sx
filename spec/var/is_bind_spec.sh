#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_bind'
    Include ./sx.sh

    It '基本的なバインドを検証すること'
        When call sx_var_is_bind "a:b:c"
        The status should be success
    End

    It 'スキップ（空の要素）を含むバインドを検証すること'
        When call sx_var_is_bind "a::c" ":b" "a:" "::"
        The status should be success
    End

    It '単一の変数名をバインドとして検証すること'
        When call sx_var_is_bind "myvar" "_"
        The status should be success
    End

    It '空文字列をバインドとして検証すること'
        When call sx_var_is_bind ""
        The status should be success
    End

    It '無効な文字（ハイフンなど）を拒否すること'
        When call sx_var_is_bind "a-b:c"
        The status should be failure
    End

    It '数字で始まる要素を許可または拒否すること'
        When call sx_var_is_bind "1a:b" "3:" "2x:y"
        The status should be success
    End

    It '数値プレフィックスの名前で始まる要素を許可すること'
        When call sx_var_is_bind "1a0:b" "3x:2y:z"
        The status should be success
    End

    It '末尾の要素が数字で始まる場合は拒否すること'
        When call sx_var_is_bind "a:2b" "3"
        The status should be failure
    End

    It 'その他の無効な文字を拒否すること'
        When call sx_var_is_bind "a.b" "a=b" "a b"
        The status should be failure
    End

    It '先頭に 0 を持つカウントを拒否すること'
        When call sx_var_is_bind "0:" "a:0:b" "01a:b" "a:00b:c" "a:0b:c"
        The status should be failure
    End

    It '複数桁のカウントを許可すること'
        When call sx_var_is_bind "12v:x" "999999999v:"
        The status should be success
    End

    It '裸のカウンタを許可すること'
        When call sx_var_is_bind "a:2:b"
        The status should be success
    End

    It '変数名中間の数字をカウントとみなさないこと'
        When call sx_var_is_bind "1a:2:c3:tt4t"
        The status should be success
    End

    It '大きな値のカウントを許可すること'
        When call sx_var_is_bind "2147483648v:" "99999999999999999999999v:"
        The status should be success
    End

    It 'SX_CFG_NUM_RANGE が不正でも成功すること'
        check_invalid_config() {
            SX_CFG_NUM_RANGE=99
            sx_var_is_bind "a:b:c"
        }
        When call check_invalid_config
        The status should be success
    End

    Describe '@ 記法（配列マーカー）'
        Describe '受理ケース'
            It 'bare @name を受理すること'
                When call sx_var_is_bind "@arr"
                The status should be success
            End

            It 'scalar:@name を受理すること'
                When call sx_var_is_bind "a:@arr"
                The status should be success
            End

            It 'scalar:scalar:@name を受理すること'
                When call sx_var_is_bind "a:b:@arr2"
                The status should be success
            End

            It 'N@name:@name を受理すること'
                When call sx_var_is_bind "a:10@arr:@arr2"
                The status should be success
            End

            It 'N@name:rest を受理すること'
                When call sx_var_is_bind "a:10@arr:rest"
                The status should be success
            End

            It 'N@name:rest の先頭省略形を受理すること'
                When call sx_var_is_bind "10@arr:rest"
                The status should be success
            End

            It 'N@name の混在を受理すること'
                When call sx_var_is_bind "a:1@b:c"
                The status should be success
            End

            It '複数 N@name の混在を受理すること'
                When call sx_var_is_bind "2@a:3@b:@c"
                The status should be success
            End

            It '末尾が bare @name の裸カウンタを受理すること'
                When call sx_var_is_bind "a:2:@arr"
                The status should be success
            End

            It '大きな N の @name を受理すること'
                When call sx_var_is_bind "99999@arr:rest"
                The status should be success
            End

            It '複数 @name を含むバインドを受理すること'
                When call sx_var_is_bind "2@a:3@b:@c"
                The status should be success
            End

            It '空セグメントと @name を含むバインドを受理すること'
                When call sx_var_is_bind "a::@arr"
                The status should be success
            End

            It '複数引数で @name を受理すること'
                When call sx_var_is_bind "@arr" "@arr2"
                The status should be success
            End

            It '複数引数で同名 arr を受理すること'
                When call sx_var_is_bind "@a" "@a"
                The status should be success
            End

            It '複数引数で scalar と arr の同名列が独立に受理されること'
                When call sx_var_is_bind "a:" "@a"
                The status should be success
            End
        End

        Describe '拒否ケース - 構文'
            It 'bare @ を拒否すること'
                When call sx_var_is_bind "@"
                The status should be failure
            End

            It '@: を拒否すること'
                When call sx_var_is_bind "@:"
                The status should be failure
            End

            It 'a:@ を拒否すること'
                When call sx_var_is_bind "a:@"
                The status should be failure
            End

            It 'a:@: を拒否すること'
                When call sx_var_is_bind "a:@:"
                The status should be failure
            End

            It '@N: (数字名) を拒否すること'
                When call sx_var_is_bind "@1:x"
                The status should be failure
            End

            It 'a:@1:x を拒否すること'
                When call sx_var_is_bind "a:@1:x"
                The status should be failure
            End

            It 'a:10@1:x を拒否すること'
                When call sx_var_is_bind "a:10@1:x"
                The status should be failure
            End

            It 'name@suffix 形式を拒否すること'
                When call sx_var_is_bind "a@b"
                The status should be failure
            End

            It '@a@b 形式を拒否すること'
                When call sx_var_is_bind "@a@b"
                The status should be failure
            End

            It 'a:2@b@c:x 形式を拒否すること'
                When call sx_var_is_bind "a:2@b@c:x"
                The status should be failure
            End

            It '@a:b (@ が先頭セグメント) を拒否すること'
                When call sx_var_is_bind "@a:b"
                The status should be failure
            End

            It 'a:@arr:b (@ が中間セグメント) を拒否すること'
                When call sx_var_is_bind "a:@arr:b"
                The status should be failure
            End

            It '@a:@b:c (中間 bare @ を含む複数 @) を拒否すること'
                When call sx_var_is_bind "@a:@b:c"
                The status should be failure
            End

            It '@a:@a (中間 bare @) を拒否すること'
                When call sx_var_is_bind "@a:@a"
                The status should be failure
            End

            It '複数引数の引数内で bare @ 中間セグメントを拒否すること'
                When call sx_var_is_bind "@a" "@a:x"
                The status should be failure
            End

            It '0@a:x を拒否すること'
                When call sx_var_is_bind "0@a:x"
                The status should be failure
            End

            It 'a:0@b:c を拒否すること'
                When call sx_var_is_bind "a:0@b:c"
                The status should be failure
            End

            It 'a:01@b:c を拒否すること'
                When call sx_var_is_bind "a:01@b:c"
                The status should be failure
            End

            It '末尾 N@name を拒否すること'
                When call sx_var_is_bind "a:2@arr" "a:10@arr"
                The status should be failure
            End

            It '不正な文字を含む @name を拒否すること'
                When call sx_var_is_bind "a:@a-b:x"
                The status should be failure
            End
        End

        Describe '拒否ケース - 型衝突'
            It 'scalar と arr の混在を拒否すること (a:10@a:)'
                When call sx_var_is_bind "a:10@a:"
                The status should be failure
            End

            It 'arr と scalar の混在を拒否すること (10@a:a)'
                When call sx_var_is_bind "10@a:a"
                The status should be failure
            End

            It 'list と list の同名再利用を拒否すること (a:2a:x)'
                When call sx_var_is_bind "a:2a:x"
                The status should be failure
            End

            It 'list の逆順再利用を拒否すること (2a:a:x)'
                When call sx_var_is_bind "2a:a:x"
                The status should be failure
            End

            It '末尾素名 list 化により a:a を拒否すること'
                When call sx_var_is_bind "a:a"
                The status should be failure
            End

            It 'scalar と list の同引数混在を拒否すること (v:2v:)'
                When call sx_var_is_bind "v:2v:" "v:2v"
                The status should be failure
            End

            It 'scalar と arr の同引数混在を拒否すること (a:10@a:x)'
                When call sx_var_is_bind "a:10@a:x"
                The status should be failure
            End
        End

        Describe '受理ケース - 型の再利用'
            It 'list の同名再利用を受理すること (2a:3a:x)'
                When call sx_var_is_bind "2a:3a:x"
                The status should be success
            End

            It 'arr の同名再利用を受理すること (2@a:3@a:x)'
                When call sx_var_is_bind "2@a:3@a:x"
                The status should be success
            End

            It '複数引数で arr の同名再利用を受理すること'
                When call sx_var_is_bind "@a" "2@a:x"
                The status should be success
            End

            It 'scalar の再利用を受理すること'
                When call sx_var_is_bind "a:x:a:y"
                The status should be success
            End
        End

        Describe '状態分離 - リーク防止'
            It '成功後に次の呼び出しが正しく動作すること'
                sx_var_is_bind "@arr" || :
                When call sx_var_is_bind "a:10@x:y"
                The status should be success
            End

            It '失敗後に次の呼び出しが正しく動作すること'
                sx_var_is_bind "a-b" || :
                When call sx_var_is_bind "a:10@x:y"
                The status should be success
            End

            It '型衝突の失敗後に次の呼び出しが正しく動作すること'
                sx_var_is_bind "a:10@a:" || :
                When call sx_var_is_bind "2a:3a:x"
                The status should be success
            End

            It '不正文字の失敗後に次の呼び出しが正しく動作すること'
                sx_var_is_bind "@a:b" || :
                When call sx_var_is_bind "@arr"
                The status should be success
            End

            It '末尾数字検査の失敗後に次の呼び出しが正しく動作すること'
                sx_var_is_bind "a:2@arr" || :
                When call sx_var_is_bind "a:@arr"
                The status should be success
            End

            It 'SX_CFG_NUM_RANGE が不正でも @ 付きバインドが受理されること'
                check_invalid_config_arr() {
                    SX_CFG_NUM_RANGE=99
                    sx_var_is_bind "a:@arr"
                }
                When call check_invalid_config_arr
                The status should be success
            End
        End
    End
End
