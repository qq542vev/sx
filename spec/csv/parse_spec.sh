#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh
# ShellSpec の構文・動的結果変数・間接コールバックと、シェル構文を含む文字列を検証する。
# shellcheck disable=SC2016,SC2154,SC2286,SC2288,SC2317,SC2329

Describe 'sx_csv_parse'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_csv_parse)
        sxtest_load ./build/modules/sx_csv_parse.sh
        ;;
      __sx_csv_parse)
        sxtest_load ./build/modules/__sx_csv_parse.sh
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/run.sh
  tab=$(printf '\t')

  It 'ヘッダを含む各行を SX 配列として保存する'
    Set 'allexport:on'
    load_subject sx_csv_parse
    data="name,age${SX_STR_LF}alice,15${SX_STR_LF}bob,13${SX_STR_LF}"
    When call sx_csv_parse res "$data"
    The status should be success
    The variable res_len should equal 3
    The variable res_0_len should equal 2
    The variable res_0_0 should equal name
    The variable res_0_1 should equal age
    The variable res_1_0 should equal alice
    The variable res_1_1 should equal 15
    The variable res_2_1 should equal 13
    The variable res_3 should be undefined
    Assert sxtest_run -- 'sx_var_is_arr "$@"' res res_0 res_1 res_2
  End

  It '引用内の区切り・改行と二重化された引用符を復元する'
    load_subject sx_csv_parse
    data="\"a,b\",\"c\"\"d\"${SX_STR_CR}${SX_STR_LF}\"x${SX_STR_CR}${SX_STR_LF}y${SX_STR_LF}z\",end"
    When call sx_csv_parse res "$data"
    The status should be success
    The variable res_len should equal 2
    The variable res_0_0 should equal 'a,b'
    The variable res_0_1 should equal 'c"d'
    The variable res_1_0 should equal "x${SX_STR_CR}${SX_STR_LF}y${SX_STR_LF}z"
    The variable res_1_1 should equal end
  End

  It '空入力は行を作らない'
    Set 'allexport:on'
    load_subject sx_csv_parse
    When call sx_csv_parse res ''
    The status should be success
    The variable res_len should equal 0
    The variable res_0 should be undefined
    Assert sxtest_run -- 'sx_var_is_arr "$@"' res
  End

  It '途中の空行は空フィールド一つの配列にする'
    load_subject sx_csv_parse
    When call sx_csv_parse res "a,b${SX_STR_LF}${SX_STR_LF}c,d"
    The status should be success
    The variable res_len should equal 3
    The variable res_1_len should equal 1
    The variable res_1_0 should equal ''
    The variable res_2_1 should equal d
  End

  It 'CRLF の空行も保存し末尾改行だけでは行を増やさない'
    load_subject sx_csv_parse
    When call sx_csv_parse res "${SX_STR_CR}${SX_STR_LF}${SX_STR_CR}${SX_STR_LF}"
    The status should be success
    The variable res_len should equal 2
    The variable res_0_len should equal 1
    The variable res_0_0 should equal ''
    The variable res_1_0 should equal ''
    The variable res_2 should be undefined
  End

  It 'LF 直前の CR だけを除き区切り前・末尾・連続した CR は保持する'
    load_subject sx_csv_parse
    data="a${SX_STR_CR},b${SX_STR_CR}${SX_STR_CR}${SX_STR_LF}c${SX_STR_CR},d${SX_STR_CR}"
    When call sx_csv_parse res "$data"
    The status should be success
    The variable res_len should equal 2
    The variable res_0_len should equal 2
    The variable res_0_0 should equal "a${SX_STR_CR}"
    The variable res_0_1 should equal "b${SX_STR_CR}"
    The variable res_1_len should equal 2
    The variable res_1_0 should equal "c${SX_STR_CR}"
    The variable res_1_1 should equal "d${SX_STR_CR}"
  End

  It '先頭・連続・末尾と引用された空フィールドを保存する'
    load_subject sx_csv_parse
    When call sx_csv_parse res ',,"",'
    The status should be success
    The variable res_0_len should equal 4
    The variable res_0_0 should equal ''
    The variable res_0_1 should equal ''
    The variable res_0_2 should equal ''
    The variable res_0_3 should equal ''
  End

  Context '非引用フィールドの CR と行区切り'
    Parameters
      ',' '"'
      ',' ''
      '' '"'
      '' ''
    End

    It '列区切り・引用の有効無効にかかわらず LF 直前の CR 一つだけを除く'
      load_subject sx_csv_parse
      data="a${SX_STR_CR}${SX_STR_CR}${SX_STR_LF}b${SX_STR_CR}"
      When call sx_csv_parse res "$data" '' "$1" "$2"
      The status should be success
      The variable res_len should equal 2
      The variable res_0_len should equal 1
      The variable res_0_0 should equal "a${SX_STR_CR}"
      The variable res_1_0 should equal "b${SX_STR_CR}"
    End
  End

  It '引用フィールド末尾の CR は後続の LF・CRLF にかかわらず保持する'
    load_subject sx_csv_parse
    data="\"a${SX_STR_CR}\"${SX_STR_LF}\"b${SX_STR_CR}\"${SX_STR_CR}${SX_STR_LF}"
    When call sx_csv_parse res "$data"
    The status should be success
    The variable res_len should equal 2
    The variable res_0_0 should equal "a${SX_STR_CR}"
    The variable res_1_0 should equal "b${SX_STR_CR}"
  End

  It 'CR だけの非引用フィールドを区切り前・入力末尾でも保持する'
    load_subject sx_csv_parse
    When call sx_csv_parse res "${SX_STR_CR},${SX_STR_CR}"
    The status should be success
    The variable res_len should equal 1
    The variable res_0_len should equal 2
    The variable res_0_0 should equal "$SX_STR_CR"
    The variable res_0_1 should equal "$SX_STR_CR"
  End

  It '末尾の空フィールドをレコード区切り前でも保存する'
    load_subject sx_csv_parse
    When call sx_csv_parse res "a,${SX_STR_LF}"
    The status should be success
    The variable res_len should equal 1
    The variable res_0_len should equal 2
    The variable res_0_1 should equal ''
  End

  It '引用された空文字列だけでも一行一フィールドを作る'
    load_subject sx_csv_parse
    When call sx_csv_parse res '""'
    The status should be success
    The variable res_len should equal 1
    The variable res_0_len should equal 1
    The variable res_0_0 should equal ''
  End

  It '空白と数値表記を変換せず列数の違いを許可する'
    load_subject sx_csv_parse
    When call sx_csv_parse res " 001 ,+02${SX_STR_LF} single "
    The status should be success
    The variable res_0_0 should equal ' 001 '
    The variable res_0_1 should equal '+02'
    The variable res_1_len should equal 1
    The variable res_1_0 should equal ' single '
  End

  It '複数文字区切りを引用内では保存し末尾の空フィールドも作る'
    load_subject sx_csv_parse
    When call sx_csv_parse res 'a||"b||c"||||' '' '||'
    The status should be success
    The variable res_0_len should equal 4
    The variable res_0_0 should equal a
    The variable res_0_1 should equal 'b||c'
    The variable res_0_2 should equal ''
    The variable res_0_3 should equal ''
  End

  It 'glob の特殊文字を含む区切りもリテラルとして扱う'
    load_subject sx_csv_parse
    When call sx_csv_parse res 'a[*?]b[*?]' '' '[*?]'
    The status should be success
    The variable res_0_len should equal 3
    The variable res_0_0 should equal a
    The variable res_0_1 should equal b
    The variable res_0_2 should equal ''
  End

  It '区切りの部分一致と重なりを左から処理する'
    load_subject sx_csv_parse
    When call sx_csv_parse res 'xaaay,a' '' aa
    The status should be success
    The variable res_0_len should equal 2
    The variable res_0_0 should equal x
    The variable res_0_1 should equal 'ay,a'
  End

  Context '列区切りなし'
    It 'カンマ・複数文字区切り・タブを分割せず各レコードを一カラムにする'
      load_subject sx_csv_parse
      data="a,b||c${tab}d${SX_STR_LF}x,y"
      When call sx_csv_parse res "$data" '' ''
      The status should be success
      The variable res_len should equal 2
      The variable res_0_len should equal 1
      The variable res_0_0 should equal "a,b||c${tab}d"
      The variable res_1_len should equal 1
      The variable res_1_0 should equal 'x,y'
    End

    It '空入力は空配列にする'
      load_subject sx_csv_parse
      When call sx_csv_parse res '' '' ''
      The status should be success
      The variable res_len should equal 0
      The variable res_0 should be undefined
    End

    It 'CRLF・LF の空行を保存し末尾改行では行を増やさない'
      load_subject sx_csv_parse
      When call sx_csv_parse res "${SX_STR_CR}${SX_STR_LF}${SX_STR_LF}last${SX_STR_LF}" '' ''
      The status should be success
      The variable res_len should equal 3
      The variable res_0_len should equal 1
      The variable res_0_0 should equal ''
      The variable res_1_len should equal 1
      The variable res_1_0 should equal ''
      The variable res_2_len should equal 1
      The variable res_2_0 should equal last
      The variable res_3 should be undefined
    End

    It '引用内の改行・二重化された引用符・引用された空文字列を処理する'
      load_subject sx_csv_parse
      data="\"a,b${SX_STR_LF}c\"${SX_STR_CR}${SX_STR_LF}\"d\"\"e\"${SX_STR_LF}\"\""
      When call sx_csv_parse res "$data" '' ''
      The status should be success
      The variable res_len should equal 3
      The variable res_0_len should equal 1
      The variable res_0_0 should equal "a,b${SX_STR_LF}c"
      The variable res_1_len should equal 1
      The variable res_1_0 should equal 'd"e'
      The variable res_2_len should equal 1
      The variable res_2_0 should equal ''
    End

    It '複数の引用符候補をレコードごとに使い分けられる'
      load_subject sx_csv_parse
      When call sx_csv_parse res "'a,b'${SX_STR_LF}\"c'd\"" '' '' "\"'"
      The status should be success
      The variable res_len should equal 2
      The variable res_0_len should equal 1
      The variable res_0_0 should equal 'a,b'
      The variable res_1_len should equal 1
      The variable res_1_0 should equal "c'd"
    End

    It '引用処理も無効なら引用符を含む各行をそのまま保存する'
      load_subject sx_csv_parse
      data="'a,b\",c${SX_STR_LF}\"d,e'"
      When call sx_csv_parse res "$data" '' '' ''
      The status should be success
      The variable res_len should equal 2
      The variable res_0_len should equal 1
      The variable res_0_0 should equal "'a,b\",c"
      The variable res_1_len should equal 1
      The variable res_1_0 should equal "\"d,e'"
    End

    It '入力先頭の X やコロンを列区切り有効の印と混同しない'
      load_subject sx_csv_parse
      When call sx_csv_parse res "X:a,b${SX_STR_LF}:c,d${SX_STR_LF}XX:${SX_STR_LF}X:${SX_STR_LF}:" '' ''
      The status should be success
      The variable res_len should equal 5
      The variable res_0_0 should equal 'X:a,b'
      The variable res_1_0 should equal ':c,d'
      The variable res_2_0 should equal 'XX:'
      The variable res_3_0 should equal 'X:'
      The variable res_4_0 should equal ':'
    End

    Context '構文エラー'
      Parameters
        1 '"bad'
        2 'bad"'
        3 '"ok",tail'
        3 "'ok'\""
      End

      It '引用規則を維持し失敗したレコードも0列の配列として残す'
        Set 'allexport:on'
        load_subject sx_csv_parse
        When call sx_csv_parse res "first,row${SX_STR_LF}$2" '' '' "\"'"
        The status should equal "$1"
        The variable res_len should equal 2
        The variable res_0_len should equal 1
        The variable res_0_0 should equal 'first,row'
        The variable res_1_len should equal 0
        The variable res_1_0 should be undefined
        Assert sxtest_run -- 'sx_var_is_arr "$@"' res_1
      End
    End

    It '引用エラーを一カラム目として通知しコールバックの終了ステータスを返す'
      load_subject sx_csv_parse
      csv_error() { csv_error_args="$*"; return 99; }
      When call sx_csv_parse res "done${SX_STR_LF}\"bad\"tail" csv_error ''
      The status should equal 99
      The variable csv_error_args should equal '3 2 1'
      The variable res_len should equal 2
      The variable res_0_0 should equal 'done'
      The variable res_1_len should equal 0
      The variable res_1_0 should be undefined
    End
  End

  It '独自の引用符とその二重化に対応する'
    load_subject sx_csv_parse
    When call sx_csv_parse res "'a;b';'it''s'" '' ';' "'"
    The status should be success
    The variable res_0_0 should equal 'a;b'
    The variable res_0_1 should equal "it's"
  End

  It 'glob の特殊文字を引用符として使える'
    load_subject sx_csv_parse
    When call sx_csv_parse res '*a,b*,*c**d*' '' ',' '*'
    The status should be success
    The variable res_0_0 should equal 'a,b'
    The variable res_0_1 should equal 'c*d'
  End

  It '二重引用符と単一引用符をフィールドごとに使い分けられる'
    load_subject sx_csv_parse
    When call sx_csv_parse res "\"a,b\",'c,d',plain" '' ',' "\"'"
    The status should be success
    The variable res_0_len should equal 3
    The variable res_0_0 should equal 'a,b'
    The variable res_0_1 should equal 'c,d'
    The variable res_0_2 should equal plain
  End

  It '開始時とは別の引用符と引用内改行を通常文字として保存する'
    load_subject sx_csv_parse
    data="'a\"b,${SX_STR_LF}c',\"d'e,f\""
    When call sx_csv_parse res "$data" '' ',' "\"'"
    The status should be success
    The variable res_len should equal 1
    The variable res_0_0 should equal "a\"b,${SX_STR_LF}c"
    The variable res_0_1 should equal "d'e,f"
  End

  It '開始時と同じ引用符だけを二重化で復元する'
    load_subject sx_csv_parse
    data="'a\"\"b','it''s',\"c''d\",\"say \"\"hi\"\"\""
    When call sx_csv_parse res "$data" '' ',' "\"'"
    The status should be success
    The variable res_0_len should equal 4
    The variable res_0_0 should equal 'a""b'
    The variable res_0_1 should equal "it's"
    The variable res_0_2 should equal "c''d"
    The variable res_0_3 should equal 'say "hi"'
  End

  It '異なる引用符で囲んだ空フィールドと末尾の空フィールドを保存する'
    load_subject sx_csv_parse
    When call sx_csv_parse res "'',\"\"," '' ',' "\"'"
    The status should be success
    The variable res_0_len should equal 3
    The variable res_0_0 should equal ''
    The variable res_0_1 should equal ''
    The variable res_0_2 should equal ''
  End

  It '引用符候補の重複は解析結果を変えない'
    load_subject sx_csv_parse
    When call sx_csv_parse res "'a',\"b\"" '' ',' "\"''\""
    The status should be success
    The variable res_0_0 should equal a
    The variable res_0_1 should equal b
  End

  It '英字も引用符の候補として複数指定できる'
    load_subject sx_csv_parse
    When call sx_csv_parse res 'aonea,btwob' '' ',' ab
    The status should be success
    The variable res_0_0 should equal one
    The variable res_0_1 should equal two
  End

  Context '引用符集合の特殊文字'
    Parameters
      '['
      ']'
      '-'
      '!'
      '^'
      '*'
      '?'
      "\\"
    End

    It '集合内の各文字をリテラルな開始・終了引用符として扱う'
      load_subject sx_csv_parse
      data="${1}a,b${1},${1}c${1}${1}d${1}"
      When call sx_csv_parse res "$data" '' ',' "!^-][*?\\"
      The status should be success
      The variable res_0_len should equal 2
      The variable res_0_0 should equal 'a,b'
      The variable res_0_1 should equal "c${1}d"
    End
  End

  Context '引用符集合のリテラル解釈'
    Parameters
      'ahelloamaworlda' m 'a-z' hello world
      ':a5b:5:c:' 5 '[:digit:]' a5b c
    End

    It '範囲や文字クラスを作らず区切りの検証にも同じ集合を使う'
      load_subject sx_csv_parse
      When call sx_csv_parse res "$1" '' "$2" "$3"
      The status should be success
      The variable res_0_len should equal 2
      The variable res_0_0 should equal "$4"
      The variable res_0_1 should equal "$5"
    End
  End

  It '引用処理を無効にした TSV では引用符も通常文字になる'
    load_subject sx_csv_parse
    data="\"a${tab}b\"${SX_STR_LF}c${tab}${tab}"
    When call sx_csv_parse res "$data" '' "$tab" ''
    The status should be success
    The variable res_len should equal 2
    The variable res_0_0 should equal '"a'
    The variable res_0_1 should equal 'b"'
    The variable res_1_len should equal 3
    The variable res_1_1 should equal ''
    The variable res_1_2 should equal ''
  End

  It '引用無効なら二重引用符も区切りに使える'
    load_subject sx_csv_parse
    When call sx_csv_parse res 'a"b"' '' '"' ''
    The status should be success
    The variable res_0_len should equal 3
    The variable res_0_0 should equal a
    The variable res_0_1 should equal b
    The variable res_0_2 should equal ''
  End

  It 'シェル構文やバックスラッシュを実行・変換しない'
    load_subject sx_csv_parse
    data='$(csv_executed=1),`csv_executed=2`,a\b;*?[x]'
    When call sx_csv_parse res "$data"
    The status should be success
    The variable res_0_0 should equal '$(csv_executed=1)'
    The variable res_0_1 should equal '`csv_executed=2`'
    The variable res_0_2 should equal 'a\b;*?[x]'
    The variable csv_executed should be undefined
  End

  It '配列の参照・穴の設定にかかわらず文字列と空フィールドを保存する'
    Set 'allexport:on'
    load_subject sx_csv_parse
    sxtest_run SX_CFG_ARR_REF SX_CFG_ARR_HOLE -- 'sx_cfg_set "$@"' 'ARR_REF=@' 'ARR_HOLE=hole'
    src=referenced
    before_rev=$SX_SYS_REV
    When call sx_csv_parse res '@src,hole,'
    The status should be success
    The variable res_0_len should equal 3
    The variable res_0_0 should equal '@src'
    The variable res_0_1 should equal hole
    The variable res_0_2 should equal ''
    Assert sxtest_run -- 'sx_var_is_arr "$@"' res res_0
    The variable SX_SYS_REV should not equal "$before_rev"
    The variable res should not equal "$res_0"
    The variable SX_CFG_ARR_REF should equal '@'
    The variable SX_CFG_ARR_HOLE should equal hole
  End

  It '呼び出し側で削除してから短い結果を再代入できる'
    load_subject sx_csv_parse
    setup_command='
      SX_SYS_REV=$1
      sx_csv_parse res "a,b,c${SX_STR_LF}d,e"
      sx_arr_gen res_0_0 nested
      sx_var_unset res
    '
    sxtest_run res res_len res_0 res_0_len res_0_0 res_0_0_len res_0_0_0 res_0_1 res_0_2 res_1 res_1_len res_1_0 res_1_1 SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
    When call sx_csv_parse res z
    The status should be success
    The variable res_len should equal 1
    The variable res_0_len should equal 1
    The variable res_0_0 should equal z
    The variable res_0_0_len should be undefined
    The variable res_0_0_0 should be undefined
    The variable res_0_1 should be undefined
    The variable res_1 should be undefined
    The variable res_1_len should be undefined
    The variable res_1_0 should be undefined
  End

  It '呼び出し側で削除してから空入力を再代入できる'
    load_subject sx_csv_parse
    setup_command='
      SX_SYS_REV=$1
      sx_csv_parse res "a,b"
      sx_var_unset res
    '
    sxtest_run res res_len res_0 res_0_len res_0_0 res_0_1 SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
    When call sx_csv_parse res ''
    The status should be success
    The variable res_len should equal 0
    The variable res_0 should be undefined
    The variable res_0_0 should be undefined
  End

  Context '構文エラー'
    Parameters
      1 '"unclosed'
      2 'un"quoted'
      3 '"closed"suffix'
      3 '"closed" '
      1 '"""'
    End

    It '完成行と失敗行の確定済みフィールドを残して原因別の終了ステータスを返す'
      Set 'allexport:on'
      load_subject sx_csv_parse
      setup_command='
        SX_SYS_REV=$1
        sx_csv_parse res "old,value"
        sx_var_unset res
      '
      sxtest_run res res_len res_0 res_0_len res_0_0 res_0_1 SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
      When call sx_csv_parse res "a,b${SX_STR_LF}first,$2"
      The status should equal "$1"
      The variable res_len should equal 2
      The variable res_0_0 should equal a
      The variable res_0_1 should equal b
      The variable res_1_len should equal 1
      The variable res_1_0 should equal first
      The variable res_1_1 should be undefined
      The variable res_2 should be undefined
      Assert sxtest_run -- 'sx_var_is_arr "$@"' res_1
    End
  End

  Context '複数の引用符を有効にした場合の構文エラー'
    Parameters
      1 "\"bad'"
      1 "'bad\""
      1 "'bad''"
      2 "bad'"
      2 'bad"'
      3 "'ok'\""
      3 "\"ok\"'"
    End

    It '別の引用符で閉じることや非引用フィールド内の引用符を拒否する'
      load_subject sx_csv_parse
      When call sx_csv_parse res "a,b${SX_STR_LF}first,$2" '' ',' "\"'"
      The status should equal "$1"
      The variable res_len should equal 2
      The variable res_0_0 should equal a
      The variable res_0_1 should equal b
      The variable res_1_len should equal 1
      The variable res_1_0 should equal first
      The variable res_1_1 should be undefined
    End
  End

  Context '第1行の第1列での構文エラー'
    Parameters
      1 '"unclosed'
      2 'un"quoted'
      3 '"closed"suffix'
    End

    It '失敗した列を含めず0列の行を残す'
      Set 'allexport:on'
      load_subject sx_csv_parse
      When call sx_csv_parse res "$2"
      The status should equal "$1"
      The variable res_len should equal 1
      The variable res_0_len should equal 0
      The variable res_0_0 should be undefined
      The variable res_1 should be undefined
      Assert sxtest_run -- 'sx_var_is_arr "$@"' res res_0
    End
  End

  It 'エラーコードと論理的な行・列を通知しコールバックの終了ステータスを返す'
    load_subject sx_csv_parse
    csv_error() {
      csv_error_args="$*"
      csv_error_rows=$res_len
      csv_error_fields=$res_1_len
      return 99
    }
    When call sx_csv_parse res "\"a${SX_STR_LF}b\",c${SX_STR_LF}x,y,\"bad\"z" csv_error
    The status should equal 99
    The variable csv_error_args should equal '3 2 3'
    The variable csv_error_rows should equal 2
    The variable csv_error_fields should equal 2
    The variable res_len should equal 2
    The variable res_1_len should equal 2
    The variable res_1_0 should equal x
    The variable res_1_1 should equal y
    The variable res_1_2 should be undefined
  End

  It '引用エラーの位置を空フィールドも数えて通知する'
    load_subject sx_csv_parse
    csv_error() { csv_error_args="$*"; }
    When call sx_csv_parse res ',,"bad' csv_error
    The status should be success
    The variable csv_error_args should equal '1 1 3'
    The variable res_len should equal 1
    The variable res_0_len should equal 2
    The variable res_0_0 should equal ''
    The variable res_0_1 should equal ''
    The variable res_0_2 should be undefined
  End

  It 'エラーでも配列設定を保持しコールバックにも元の設定を渡す'
    load_subject sx_csv_parse
    sxtest_run SX_CFG_ARR_REF SX_CFG_ARR_HOLE -- 'sx_cfg_set "$@"' 'ARR_REF=@' 'ARR_HOLE=hole'
    src=referenced
    csv_error() {
      csv_error_cfg="${SX_CFG_ARR_REF}:${SX_CFG_ARR_HOLE}"
    }
    When call sx_csv_parse res "@src,hole${SX_STR_LF}\"bad" csv_error
    The status should be success
    The variable res_len should equal 2
    The variable res_0_0 should equal '@src'
    The variable res_0_1 should equal hole
    The variable res_1_len should equal 0
    The variable res_1_0 should be undefined
    The variable csv_error_cfg should equal '@:hole'
    The variable SX_CFG_ARR_REF should equal '@'
    The variable SX_CFG_ARR_HOLE should equal hole
  End

  It '成功時にはエラーコールバックを呼ばない'
    load_subject sx_csv_parse
    csv_error() { csv_error_called=1; }
    When call sx_csv_parse res a csv_error
    The status should be success
    The variable csv_error_called should be undefined
  End

  It 'コールバックから再入しても通知引数と完成行・失敗行を保持する'
    load_subject sx_csv_parse
    csv_error() {
      sx_csv_parse nested "'inner',\"value\"" '' ',' "\"'"
      csv_error_args="$*"
      return "$1"
    }
    When call sx_csv_parse res "a,b${SX_STR_LF}bad'" csv_error ',' "\"'"
    The status should equal 2
    The variable csv_error_args should equal '2 2 1'
    The variable res_len should equal 2
    The variable res_0_0 should equal a
    The variable res_1_len should equal 0
    The variable res_1_0 should be undefined
    The variable nested_0_1 should equal value
  End

  Context '引数検証'
    Parameters
      ''
      '1invalid'
      'invalid-name'
      'res:other'
    End

    It '配列名が不正なら EX_USAGE を返す'
      load_subject sx_csv_parse
      When call sx_csv_parse "$1" a
      The status should equal 64
    End
  End

  It '結果変数名の省略を拒否する'
    load_subject sx_csv_parse
    When call sx_csv_parse
    The status should equal 64
    The variable res should be undefined
  End

  It '第6引数以降を無視して通常どおり解析する'
    load_subject sx_csv_parse
    When call sx_csv_parse res 'a,b' '' ',' '"' extra 'ignored;argument'
    The status should be success
    The variable res_len should equal 1
    The variable res_0_len should equal 2
    The variable res_0_0 should equal a
    The variable res_0_1 should equal b
  End

  Context '区切りと引用符の検証'
    Parameters
      '||' '|'
      'xy' 'abx'
      'xy' 'yab'
      'xy' 'ayb'
      'x]y' '[]'
      'x-y' 'a-z'
    End

    It '引用符集合内の文字を含む区切りを拒否する'
      load_subject sx_csv_parse
      sx_csv_parse res original
      When call sx_csv_parse res a '' "$1" "$2"
      The status should equal 64
      The variable res_0_0 should equal original
    End
  End

  It 'レコード区切りを sep に含める指定を拒否する'
    load_subject sx_csv_parse
    When call sx_csv_parse res a '' "x${SX_STR_LF}"
    The status should equal 64
  End

  It '改行を引用符にする指定を拒否する'
    load_subject sx_csv_parse
    When call sx_csv_parse res a '' ',' "$SX_STR_CR"
    The status should equal 64
  End

  It '引用符集合の途中に CR があっても解析前に拒否する'
    load_subject sx_csv_parse
    res=original
    When call sx_csv_parse res a '' ',' "'${SX_STR_CR}\""
    The status should equal 64
    The variable res should equal original
  End

  It '引用符集合の途中に LF があっても解析前に拒否する'
    load_subject sx_csv_parse
    res=original
    When call sx_csv_parse res a '' ',' "'${SX_STR_LF}\""
    The status should equal 64
    The variable res should equal original
  End

  Context '変数名には使えないコマンド名の通知'
    prepare_csv_callback() {
      csv_callback_dir=$(mktemp -d "${TMPDIR:-/tmp}/sx csv.XXXXXX")
      printf '%s\n' '#!/bin/sh' 'printf "%s:%s:%s:%s\n" "$#" "$1" "$2" "$3"' 'exit 99' \
        > "$csv_callback_dir/bad;callback"
      chmod +x "$csv_callback_dir/bad;callback"
      PATH="$csv_callback_dir:$PATH"
      export PATH
    }
    cleanup_csv_callback() { rm -rf -- "$csv_callback_dir"; }
    BeforeEach prepare_csv_callback
    AfterEach cleanup_csv_callback

    It '成功時にはコマンドを呼び出さない'
      load_subject sx_csv_parse
      When call sx_csv_parse res a 'bad;callback'
      The status should be success
      The stdout should equal ''
      The variable res_0_0 should equal a
    End

    It '構文エラー時にはコマンドへ通知引数を渡して終了ステータスを返す'
      load_subject sx_csv_parse
      When call sx_csv_parse res "a,b${SX_STR_LF}x,\"bad" 'bad;callback'
      The status should equal 99
      The stdout should equal '3:1:2:2'
      The variable res_len should equal 2
      The variable res_0_0 should equal a
      The variable res_0_1 should equal b
      The variable res_1_len should equal 1
      The variable res_1_0 should equal x
      The variable res_1_1 should be undefined
    End
  End

  Context '配列設定の書込可否'
    Parameters
      SX_CFG_ARR_HOLE
      SX_CFG_ARR_REF
    End

    It "$1 が readonly なら結果・設定・リビジョンを変更せず EX_NOPERM を返す"
      load_subject sx_csv_parse
      sxtest_run SX_CFG_ARR_REF SX_CFG_ARR_HOLE -- 'sx_cfg_set "$@"' 'ARR_REF=@' 'ARR_HOLE=hole'
      sx_csv_parse res original
      before_res=$res before_row=$res_0 before_rev=$SX_SYS_REV
      readonly "$1"
      When call sx_csv_parse res 'new,value'
      The status should equal 77
      The variable res should equal "$before_res"
      The variable res_len should equal 1
      The variable res_0 should equal "$before_row"
      The variable res_0_len should equal 1
      The variable res_0_0 should equal original
      The variable res_0_1 should be undefined
      The variable SX_CFG_ARR_HOLE should equal hole
      The variable SX_CFG_ARR_REF should equal '@'
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It 'res 本体が readonly なら EX_NOPERM を返す'
    load_subject sx_csv_parse
    readonly res=original
    When call sx_csv_parse res a
    The status should equal 77
    The variable res should equal original
  End

  It '新規に作る行の配下が readonly でも解析前に拒否する'
    load_subject sx_csv_parse
    res=original
    readonly res_0_1
    When call sx_csv_parse res a
    The status should equal 77
    The variable res should equal original
  End

  It '既存配列の子孫が readonly なら構造を保持する'
    load_subject sx_csv_parse
    sx_csv_parse res 'a,b'
    readonly res_0_1
    When call sx_csv_parse res z
    The status should equal 77
    The variable res_0_len should equal 2
    The variable res_0_0 should equal a
    The variable res_0_1 should equal b
  End

  It '数値範囲設定が不正なら結果を変更しない'
    load_subject sx_csv_parse
    res=original
    SX_CFG_NUM_RANGE=invalid
    When call sx_csv_parse res a
    The status should equal 78
    The variable res should equal original
  End

  Context '内部関数と検証省略'
    Parameters
      sx_csv_parse 0
      sx_csv_parse 1
      __sx_csv_parse 0
    End

    It '各経路で data の省略を空入力として扱う'
      Set 'allexport:on'
      load_subject "$1"
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" res
      The status should be success
      The variable res_len should equal 0
      The variable res_0 should be undefined
      Assert sxtest_run -- 'sx_var_is_arr "$@"' res
    End

    It '公開・内部・検証省略の各経路が同じ配列を作る'
      load_subject "$1"
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" res '"a||b"||' '' '||'
      The status should be success
      The variable res_0_len should equal 2
      The variable res_0_0 should equal 'a||b'
      The variable res_0_1 should equal ''
    End

    It '各経路で失敗行の参照・穴・空フィールドを文字列として残しリビジョンを更新する'
      Set 'allexport:on'
      load_subject "$1"
      sxtest_run SX_CFG_SKIP_CHK SX_CFG_ARR_REF SX_CFG_ARR_HOLE -- 'sx_cfg_set "$@"' "SKIP_CHK=$2" 'ARR_REF=@' 'ARR_HOLE=hole'
      src=referenced
      before_rev=$SX_SYS_REV
      When call "$1" res '@src||hole||||"bad' '' '||'
      The status should equal 1
      The variable res_len should equal 1
      The variable res_0_len should equal 3
      The variable res_0_0 should equal '@src'
      The variable res_0_1 should equal hole
      The variable res_0_2 should equal ''
      The variable res_0_3 should be undefined
      The variable SX_SYS_REV should not equal "$before_rev"
      The variable res should not equal "$res_0"
      The variable SX_CFG_ARR_REF should equal '@'
      The variable SX_CFG_ARR_HOLE should equal hole
      Assert sxtest_run -- 'sx_var_is_arr "$@"' res res_0
    End

    It '各経路で開始引用符をフィールドごとに選び直す'
      load_subject "$1"
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" res "'a||b'||\"c'd\"||" '' '||' "\"'"
      The status should be success
      The variable res_0_len should equal 3
      The variable res_0_0 should equal 'a||b'
      The variable res_0_1 should equal "c'd"
      The variable res_0_2 should equal ''
    End

    It '各経路で空の sep を列区切りなしとして扱う'
      load_subject "$1"
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" res "\"a,b\"${SX_STR_LF}c,d" '' ''
      The status should be success
      The variable res_len should equal 2
      The variable res_0_len should equal 1
      The variable res_0_0 should equal 'a,b'
      The variable res_1_len should equal 1
      The variable res_1_0 should equal 'c,d'
    End

    It '各経路で sep と quote の両方を空指定できる'
      load_subject "$1"
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
      When call "$1" res "a,'b\"" '' '' ''
      The status should be success
      The variable res_len should equal 1
      The variable res_0_len should equal 1
      The variable res_0_0 should equal "a,'b\""
    End
  End
End
