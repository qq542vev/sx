#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_to_ebind'
    Include ./sx.sh

    It '課題例を変換すること'
        When call sx_var_to_ebind res '2:3a:b:9@c:2a:2d::d'
        The status should be success
        The variable res should equal '0/2:0/3a:b:0/9@c:3/5a:0/2d::2/d'
    End

    It '末尾restをM/化すること'
        When call sx_var_to_ebind res 'a:b:c'
        The status should be success
        The variable res should equal 'a:b:0/c'
    End

    It '同名listを合算すること'
        When call sx_var_to_ebind res '2a:3a:x'
        The status should be success
        The variable res should equal '0/2a:2/5a:0/x'
    End

    It '空・単一・配列restを変換すること'
        When call sx_var_to_ebind res ''
        The status should be success
        The variable res should equal ''
    End

    It '単一変数をrest化すること'
        When call sx_var_to_ebind res 'myvar'
        The status should be success
        The variable res should equal '0/myvar'
    End

    It '配列restを変換すること'
        When call sx_var_to_ebind res '@arr'
        The status should be success
        The variable res should equal '0/@arr'
    End

    It '不正なbindを拒否すること'
        When call sx_var_to_ebind res 'a:2b'
        The status should equal 64
    End

    It '引数個数が不正な場合に64を返すこと'
        When call sx_var_to_ebind res
        The status should equal 64
    End

    It '結果変数がreadonlyの場合に77を返すこと'
        readonly ro_to_ebind
        When call sx_var_to_ebind ro_to_ebind 'a:b'
        The status should equal 77
    End

    Context 'SX_CFG_NUM_RANGE が不正のとき'
        It 'EX_CONFIG (78) を返すこと'
            check_config() {
                SX_CFG_NUM_RANGE=99
                sx_var_to_ebind res 'a:b'
            }
            When call check_config
            The status should equal 78
        End
    End
End
