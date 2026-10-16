#!/bin/sh
# shellcheck shell=sh
# ShellSpec の構文・動的結果変数・間接コールバックと、シェル構文を含む文字列を検証する。
# shellcheck disable=SC2016,SC2154,SC2286,SC2288,SC2317,SC2329

Describe 'sx_csv_parse'
  Include ./sx.sh

  It 'ヘッダを含む各行を SX 配列として保存する'
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
    Assert sx_var_is_arr res res_0 res_1 res_2
  End

  It '引用内の区切り・改行と二重化された引用符を復元する'
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
    When call sx_csv_parse res ''
    The status should be success
    The variable res_len should equal 0
    The variable res_0 should be undefined
    Assert sx_var_is_arr res
  End

  It '途中の空行は空フィールド一つの配列にする'
    When call sx_csv_parse res "a,b${SX_STR_LF}${SX_STR_LF}c,d"
    The status should be success
    The variable res_len should equal 3
    The variable res_1_len should equal 1
    The variable res_1_0 should equal ''
    The variable res_2_1 should equal d
  End

  It 'CRLF の空行も保存し末尾改行だけでは行を増やさない'
    When call sx_csv_parse res "${SX_STR_CR}${SX_STR_LF}${SX_STR_CR}${SX_STR_LF}"
    The status should be success
    The variable res_len should equal 2
    The variable res_0_len should equal 1
    The variable res_0_0 should equal ''
    The variable res_1_0 should equal ''
    The variable res_2 should be undefined
  End

  It '先頭・連続・末尾と引用された空フィールドを保存する'
    When call sx_csv_parse res ',,"",'
    The status should be success
    The variable res_0_len should equal 4
    The variable res_0_0 should equal ''
    The variable res_0_1 should equal ''
    The variable res_0_2 should equal ''
    The variable res_0_3 should equal ''
  End

  It '末尾の空フィールドをレコード区切り前でも保存する'
    When call sx_csv_parse res "a,${SX_STR_LF}"
    The status should be success
    The variable res_len should equal 1
    The variable res_0_len should equal 2
    The variable res_0_1 should equal ''
  End

  It '引用された空文字列だけでも一行一フィールドを作る'
    When call sx_csv_parse res '""'
    The status should be success
    The variable res_len should equal 1
    The variable res_0_len should equal 1
    The variable res_0_0 should equal ''
  End

  It '空白と数値表記を変換せず列数の違いを許可する'
    When call sx_csv_parse res " 001 ,+02${SX_STR_LF} single "
    The status should be success
    The variable res_0_0 should equal ' 001 '
    The variable res_0_1 should equal '+02'
    The variable res_1_len should equal 1
    The variable res_1_0 should equal ' single '
  End

  It '複数文字区切りを引用内では保存し末尾の空フィールドも作る'
    When call sx_csv_parse res 'a||"b||c"||||' '' '||'
    The status should be success
    The variable res_0_len should equal 4
    The variable res_0_0 should equal a
    The variable res_0_1 should equal 'b||c'
    The variable res_0_2 should equal ''
    The variable res_0_3 should equal ''
  End

  It 'glob の特殊文字を含む区切りもリテラルとして扱う'
    When call sx_csv_parse res 'a[*?]b[*?]' '' '[*?]'
    The status should be success
    The variable res_0_len should equal 3
    The variable res_0_0 should equal a
    The variable res_0_1 should equal b
    The variable res_0_2 should equal ''
  End

  It '区切りの部分一致と重なりを左から処理する'
    When call sx_csv_parse res 'xaaay,a' '' aa
    The status should be success
    The variable res_0_len should equal 2
    The variable res_0_0 should equal x
    The variable res_0_1 should equal 'ay,a'
  End

  It '独自の引用符とその二重化に対応する'
    When call sx_csv_parse res "'a;b';'it''s'" '' ';' "'"
    The status should be success
    The variable res_0_0 should equal 'a;b'
    The variable res_0_1 should equal "it's"
  End

  It 'glob の特殊文字を引用符として使える'
    When call sx_csv_parse res '*a,b*,*c**d*' '' ',' '*'
    The status should be success
    The variable res_0_0 should equal 'a,b'
    The variable res_0_1 should equal 'c*d'
  End

  It '引用処理を無効にした TSV では引用符も通常文字になる'
    data="\"a${SX_STR_HT}b\"${SX_STR_LF}c${SX_STR_HT}${SX_STR_HT}"
    When call sx_csv_parse res "$data" '' "$SX_STR_HT" ''
    The status should be success
    The variable res_len should equal 2
    The variable res_0_0 should equal '"a'
    The variable res_0_1 should equal 'b"'
    The variable res_1_len should equal 3
    The variable res_1_1 should equal ''
    The variable res_1_2 should equal ''
  End

  It '引用無効なら二重引用符も区切りに使える'
    When call sx_csv_parse res 'a"b"' '' '"' ''
    The status should be success
    The variable res_0_len should equal 3
    The variable res_0_0 should equal a
    The variable res_0_1 should equal b
    The variable res_0_2 should equal ''
  End

  It 'シェル構文やバックスラッシュを実行・変換しない'
    data='$(csv_executed=1),`csv_executed=2`,a\b;*?[x]'
    When call sx_csv_parse res "$data"
    The status should be success
    The variable res_0_0 should equal '$(csv_executed=1)'
    The variable res_0_1 should equal '`csv_executed=2`'
    The variable res_0_2 should equal 'a\b;*?[x]'
    The variable csv_executed should be undefined
  End

  It '配列の参照・穴・更新設定にかかわらず文字列と空フィールドを保存する'
    sx_cfg_set 'ARR_REF=@' 'ARR_HOLE=hole' 'ARR_UPDATE=0'
    src=referenced
    before_rev=$SX_SYS_REV
    When call sx_csv_parse res '@src,hole,'
    The status should be success
    The variable res_0_len should equal 3
    The variable res_0_0 should equal '@src'
    The variable res_0_1 should equal hole
    The variable res_0_2 should equal ''
    Assert sx_var_is_arr res res_0
    The variable SX_SYS_REV should not equal "$before_rev"
    The variable res should not equal "$res_0"
    The variable SX_CFG_ARR_REF should equal '@'
    The variable SX_CFG_ARR_HOLE should equal hole
    The variable SX_CFG_ARR_UPDATE should equal 0
  End

  It '短い結果で置き換える際に古い行とフィールドを再帰削除する'
    sx_csv_parse res "a,b,c${SX_STR_LF}d,e"
    sx_arr_gen res_0_0 nested
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

  It '空入力でも古い結果を削除して空配列にする'
    sx_csv_parse res 'a,b'
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

    It '完成行だけを残して原因別の終了ステータスを返す'
      sx_csv_parse res 'old,value'
      When call sx_csv_parse res "a,b${SX_STR_LF}first,$2"
      The status should equal "$1"
      The variable res_len should equal 1
      The variable res_0_0 should equal a
      The variable res_0_1 should equal b
      The variable res_1 should be undefined
      The variable res_1_len should be undefined
      The variable res_1_0 should be undefined
    End
  End

  It '先頭行でエラーになった場合は空配列を残す'
    When call sx_csv_parse res '"unclosed'
    The status should equal 1
    The variable res_len should equal 0
    The variable res_0 should be undefined
  End

  It 'エラーコードと論理的な行・列を通知しコールバックの失敗は無視する'
    csv_error() {
      csv_error_args="$*"
      csv_error_rows=$res_len
      return 99
    }
    When call sx_csv_parse res "\"a${SX_STR_LF}b\",c${SX_STR_LF}x,y,\"bad\"z" csv_error
    The status should equal 3
    The variable csv_error_args should equal '3 2 3'
    The variable csv_error_rows should equal 1
    The variable res_1 should be undefined
  End

  It '引用エラーの位置を空フィールドも数えて通知する'
    csv_error() { csv_error_args="$*"; }
    When call sx_csv_parse res ',,"bad' csv_error
    The status should equal 1
    The variable csv_error_args should equal '1 1 3'
  End

  It 'エラーでも配列設定を保持しコールバックにも元の設定を渡す'
    sx_cfg_set 'ARR_REF=@' 'ARR_HOLE=hole' 'ARR_UPDATE=0'
    src=referenced
    csv_error() {
      csv_error_cfg="${SX_CFG_ARR_REF}:${SX_CFG_ARR_HOLE}:${SX_CFG_ARR_UPDATE}"
    }
    When call sx_csv_parse res "@src,hole${SX_STR_LF}\"bad" csv_error
    The status should equal 1
    The variable res_len should equal 1
    The variable res_0_0 should equal '@src'
    The variable res_0_1 should equal hole
    The variable res_1 should be undefined
    The variable csv_error_cfg should equal '@:hole:0'
    The variable SX_CFG_ARR_REF should equal '@'
    The variable SX_CFG_ARR_HOLE should equal hole
    The variable SX_CFG_ARR_UPDATE should equal 0
  End

  It '成功時にはエラーコールバックを呼ばない'
    csv_error() { csv_error_called=1; }
    When call sx_csv_parse res a csv_error
    The status should be success
    The variable csv_error_called should be undefined
  End

  It 'コールバックから再入しても終了状態と完成行が壊れない'
    csv_error() {
      sx_csv_parse nested 'inner,value'
      csv_error_args="$*"
    }
    When call sx_csv_parse res "a,b${SX_STR_LF}bad\"" csv_error
    The status should equal 2
    The variable csv_error_args should equal '2 2 1'
    The variable res_len should equal 1
    The variable res_0_0 should equal a
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
      When call sx_csv_parse "$1" a
      The status should equal 64
    End
  End

  It '必須引数の省略を拒否する'
    When call sx_csv_parse res
    The status should equal 64
    The variable res should be undefined
  End

  It '余分な引数を拒否し既存結果を保持する'
    sx_csv_parse res original
    When call sx_csv_parse res a '' ',' '"' extra
    The status should equal 64
    The variable res_0_0 should equal original
  End

  Context '区切りと引用符の検証'
    Parameters
      '' '"'
      ',' 'ab'
      '||' '|'
    End

    It '空区切り・複数文字の引用符・区切り内の引用符を拒否する'
      sx_csv_parse res original
      When call sx_csv_parse res a '' "$1" "$2"
      The status should equal 64
      The variable res_0_0 should equal original
    End
  End

  It 'レコード区切りを sep に含める指定を拒否する'
    When call sx_csv_parse res a '' "x${SX_STR_LF}"
    The status should equal 64
  End

  It '改行を引用符にする指定を拒否する'
    When call sx_csv_parse res a '' ',' "$SX_STR_CR"
    The status should equal 64
  End

  It 'コールバック名が不正なら解析前に拒否する'
    sx_csv_parse res original
    When call sx_csv_parse res a 'bad;callback'
    The status should equal 64
    The variable res_0_0 should equal original
  End

  It 'res 本体が readonly なら EX_NOPERM を返す'
    readonly res=original
    When call sx_csv_parse res a
    The status should equal 77
    The variable res should equal original
  End

  It '新規に作る行の配下が readonly でも解析前に拒否する'
    res=original
    readonly res_0_1
    When call sx_csv_parse res a
    The status should equal 77
    The variable res should equal original
  End

  It '既存配列の子孫が readonly なら構造を保持する'
    sx_csv_parse res 'a,b'
    readonly res_0_1
    When call sx_csv_parse res z
    The status should equal 77
    The variable res_0_len should equal 2
    The variable res_0_0 should equal a
    The variable res_0_1 should equal b
  End

  It '数値範囲設定が不正なら結果を変更しない'
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

    It '公開・内部・検証省略の各経路が同じ配列を作る'
      sx_cfg_set "SKIP_CHK=$2"
      When call "$1" res '"a||b"||' '' '||'
      The status should be success
      The variable res_0_len should equal 2
      The variable res_0_0 should equal 'a||b'
      The variable res_0_1 should equal ''
    End
  End
End
