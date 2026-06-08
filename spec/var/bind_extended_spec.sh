#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '拡張バインド構文'
    Include ./sx.sh

    Describe 'sx_arg_quote'
        It '1v:rest形式で指定した数だけ変数にリストとして格納すること'
            v=
            rest=
            When call sx_arg_quote "1v:rest" "a" "b" "c" "d"
            The variable v should eq "'a'"
            The variable rest should eq "'b' 'c' 'd'"
        End

        It '2v:rest形式で2つだけ変数にリストとして格納すること'
            v=
            rest=
            When call sx_arg_quote "2v:rest" "a" "b" "c" "d"
            The variable v should eq "'a' 'b'"
            The variable rest should eq "'c' 'd'"
        End

        It '3v:形式で3つだけ変数に格納し、残りを捨てること'
            v=
            When call sx_arg_quote "3v:" "a" "b" "c" "d" "e"
            The variable v should eq "'a' 'b' 'c'"
        End

        It '2:rest形式で2つスキップすること'
            rest=
            When call sx_arg_quote "2:rest" "a" "b" "c" "d"
            The variable rest should eq "'c' 'd'"
        End

        It '10v:形式で引数が足りない場合、ある分だけ格納して成功すること'
            v=
            When call sx_arg_quote "10v:" "a" "b"
            The status should be success
            The variable v should eq "'a' 'b'"
        End
    End

    Describe 'sx_arg_find'
        It '2v:rest形式で最初に見つかった2つのインデックスを格納すること'
            v=
            rest=
            When call sx_arg_find "2v:rest" "target" 5 ::: "a" "target" "b" "target" "c" "target" "d"
            The variable v should eq "2 4"
            The variable rest should eq "6"
        End
    End

    Describe 'sx_str_split'
        It '2v:rest形式で最初の2つの要素を格納すること'
            v=
            rest=
            When call sx_str_split "2v:rest" "a,b,c,d,e" ","
            The variable v should eq "'a' 'b'"
            The variable rest should eq "'c' 'd' 'e'"
        End
    End

    Describe 'sx_arg_rquote'
        It '2v:rest形式で後ろから2つを変数に格納すること'
            v=
            rest=
            When call sx_arg_rquote "2v:rest" "a" "b" "c" "d"
            The variable v should eq "'d' 'c'"
            The variable rest should eq "'b' 'a'"
        End
    End
End
