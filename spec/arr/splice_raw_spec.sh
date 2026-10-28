#!/bin/sh
# shellcheck shell=sh
# shellcheck disable=SC2286,SC2288 # Parameters の値はコマンドではない。
# shellcheck disable=SC2016,SC2154,SC2329 # 準備用コード、参照渡し、ShellSpec のコールバック。

Describe 'sx_arr_splice_raw'
  Include ./spec/support/run.sh

  setup_splice_raw() {
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_HOLE
    sxtest_load ./build/modules/sx_arr_splice_raw.sh
    sxtest_run arr SX_SYS_REV -- 'sx_cfg_set; sx_arr_gen arr a b c'
    before_sig=$arr
    before_rev=$SX_SYS_REV
  }
  BeforeEach setup_splice_raw

  splice_raw_matches() {
    case "$arr_len" in "$#") ;; *) return 1;; esac
    slot=0
    for expected in "$@"; do
      eval 'actual_set="${arr_'"$slot"'+X}"; actual="${arr_'"$slot"'-}"'
      case "$expected" in
        hole) case "$actual_set" in '') ;; *) return 1;; esac;;
        *) case "$actual_set:$actual" in "X:$expected") ;; *) return 1;; esac;;
      esac
      slot=$((slot + 1))
    done
  }

  Context '検査省略の有無'
    Parameters
      0
      1
    End

    It '要素を操作し、元配列の署名とカウンタを保持する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      When call sx_arr_splice_raw arr 1 1 x
      The status should be success
      The variable arr_len should equal 3
      The variable arr_1 should equal x
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '削除数0で挿入値なし'
    Parameters
      0 0
      1 0
      3 0
      10000 0
      '-1' 0
      '-5' 0
      '-10000000000000000000000' 0
      1 +0
      1 '-0'
      '-10000000000000000000000' +0
      '-10000000000000000000000' '-0'
      '' 0
      +0 +0
      '-0' '-0'
    End

    It '開始位置や符号によらず配列とリビジョンを保持する'
      When call sx_arr_splice_raw arr "$1" "$2"
      The status should be success
      Assert splice_raw_matches a b c
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '空配列で削除数0かつ挿入値なし'
    Parameters
      0
      +0
      '-0'
    End

    It '巨大な負の開始位置でも空配列とリビジョンを保持する'
      sxtest_run arr arr_0 arr_1 arr_2 SX_SYS_REV -- 'sx_arr_gen arr'
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_splice_raw arr -10000000000000000000000 "$1"
      The status should be success
      Assert splice_raw_matches
      The variable arr_0 should be undefined
      The variable arr_1 should be undefined
      The variable arr_2 should be undefined
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It '変更なしの呼出しで疎な要素と入れ子配列を保持する'
    sxtest_run arr_1 arr_1_len arr_1_0 SX_SYS_REV -- 'sx_arr_gen arr_1 nested'
    unset arr_2
    before_rev=$SX_SYS_REV
    When call sx_arr_splice_raw arr -10000000000000000000000 -0
    The status should be success
    The variable arr_len should equal 3
    The variable arr_0 should equal a
    The variable arr_1_len should equal 1
    The variable arr_1_0 should equal nested
    The variable arr_2 should be undefined
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$before_rev"
  End

  It '変更なしでも無効な開始位置は64を返す'
    When call sx_arr_splice_raw arr bad 0
    The status should equal 64
    Assert splice_raw_matches a b c
  End

  It '変更なしでも配下のreadonlyは77を返す'
    readonly arr_1
    When call sx_arr_splice_raw arr 1 0
    The status should equal 77
    Assert splice_raw_matches a b c
  End

  It '変更なしでも必要設定の未設定は78を返す'
    unset SX_CFG_ARR_HOLE
    When call sx_arr_splice_raw arr 1 0
    The status should equal 78
    Assert splice_raw_matches a b c
  End

  Context '削除数0でも空文字の挿入は変更なしと区別する'
    Parameters
      0
      +0
      '-0'
    End

    It '空文字を1要素として挿入する'
      When call sx_arr_splice_raw arr 1 "$1" ''
      The status should be success
      Assert splice_raw_matches a '' b c
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It '削除数0でも穴指定の挿入は変更なしと区別する'
    sxtest_run SX_CFG_ARR_HOLE -- 'sx_cfg_set ARR_HOLE=hole'
    When call sx_arr_splice_raw arr 3 0 hole
    The status should be success
    Assert splice_raw_matches a b c hole
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$before_rev"
  End

  Context '同数の複数要素を置換する境界'
    Parameters
      0 2 X Y c
      1 2 a X Y
      1 +2 a X Y
      '-2' 2 a X Y
      2 2 a b X Y
      2 +2 a b X Y
      '-1' 2 a b X Y
      '-4' 2 X Y b c
    End

    It '範囲内なら長さを保ち、末尾を超える指定は実際の削除数に丸める'
      When call sx_arr_splice_raw arr "$1" "$2" X Y
      The status should be success
      shift 2
      Assert splice_raw_matches "$@"
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '算術幅を超える添字での等長置換と末尾超過'
    Parameters
      10000000000000000000001 10000000000000000000002 10000000000000000000003
      10000000000000000000002 10000000000000000000003 10000000000000000000004
    End

    It '終端を文字列数値として比較し、必要な場合だけ長さを増やす'
      arr_len=10000000000000000000003
      When call sx_arr_splice_raw arr "$1" +2 X Y
      The status should be success
      The variable arr_len should equal "$3"
      The variable "arr_${1}" should equal X
      The variable "arr_${2}" should equal Y
      The variable arr_0 should equal a
      The variable arr_1 should equal b
      The variable arr_2 should equal c
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '算術幅を超える長さと負の開始位置'
    Parameters
      '-1' 10000000000000000000002
      '-2' 10000000000000000000001
      '-10000000000000000000003' 0
    End

    It '負の開始位置を正規化し、指定位置だけを同数置換する'
      arr_len=10000000000000000000003
      When call sx_arr_splice_raw arr "$1" 1 X
      The status should be success
      The variable arr_len should equal 10000000000000000000003
      The variable "arr_${2}" should equal X
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '先頭前の穴がない削除範囲の境界'
    Parameters
      1 1 a X Y c d e f
      1 +3 a X Y e f
      '-5' 3 a X Y e f
      1 5 a X Y
      1 99 a X Y
      1 '-1' a X Y f
      1 '-3' a X Y d e f
      1 '-4' a X Y c d e f
      1 '-5' a X Y b c d e f
      1 '-6' a X Y b c d e f
      1 '-99' a X Y b c d e f
      1 '-10000000000000000000000' a X Y b c d e f
    End

    It '正負の削除数から縮小・同長・拡大と削除なしを区別する'
      sxtest_run arr arr_0 arr_1 arr_2 arr_3 arr_4 arr_5 SX_SYS_REV -- \
        'sx_arr_gen arr a b c d e f'
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_splice_raw arr "$1" "$2" X Y
      The status should be success
      shift 2
      Assert splice_raw_matches "$@"
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '尾部の開始位置を直接求める移動で入れ子と穴を保持'
    Parameters
      1 2 7 6
      3 4 5 4
    End

    It '拡大・縮小とも未読の入れ子を保護し、古い子変数を残さない'
      sxtest_run arr arr_0 arr_1 arr_2 arr_2_len arr_2_0 arr_3 \
        arr_4 arr_4_len arr_4_0 arr_5 SX_SYS_REV -- \
        'sx_arr_gen arr a b c d e f; sx_arr_gen "arr_$1" nested; unset arr_5' "$2"
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_splice_raw arr 1 "$1" X Y
      The status should be success
      The variable arr_len should equal "$3"
      The variable arr_0 should equal a
      The variable arr_1 should equal X
      The variable arr_2 should equal Y
      The variable arr_2_len should be undefined
      The variable arr_2_0 should be undefined
      The variable arr_3_len should equal 1
      The variable arr_3_0 should equal nested
      The variable arr_4_len should be undefined
      The variable arr_4_0 should be undefined
      The variable "arr_$4" should be undefined
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '算術幅を超える削除範囲で尾部を移動'
    Parameters
      2
      '-1'
    End

    It '正負の削除数を同じ終端へ換算し、残った1要素を移す'
      arr_len=10000000000000000000004
      arr_10000000000000000000003=tail
      When call sx_arr_splice_raw arr 10000000000000000000001 "$1" X
      The status should be success
      The variable arr_len should equal 10000000000000000000003
      The variable arr_10000000000000000000001 should equal X
      The variable arr_10000000000000000000002 should equal tail
      The variable arr_10000000000000000000003 should be undefined
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It '等長置換でも入れ子を掃除し、空文字・穴・文字列を区別する'
    sxtest_run arr arr_0 arr_0_len arr_0_0 arr_1 arr_1_len arr_1_0 \
      arr_2 arr_3 arr_3_len arr_3_0 SX_SYS_REV SX_CFG_ARR_HOLE -- \
      'sx_cfg_set ARR_HOLE=hole; sx_arr_gen arr "" "" "" ""; sx_arr_gen arr_0 old0; sx_arr_gen arr_1 old1; sx_arr_gen arr_3 old3'
    before_sig=$arr
    before_rev=$SX_SYS_REV
    When call sx_arr_splice_raw arr 0 +3 '' hole '@source'
    The status should be success
    The variable arr_len should equal 4
    The variable arr_0 should equal ''
    The variable arr_0_len should be undefined
    The variable arr_0_0 should be undefined
    The variable arr_1 should be undefined
    The variable arr_1_len should be undefined
    The variable arr_1_0 should be undefined
    The variable arr_2 should equal '@source'
    The variable arr_3_len should equal 1
    The variable arr_3_0 should equal old3
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$before_rev"
  End

  It '引数なしは64を返す'
    When call sx_arr_splice_raw
    The status should equal 64
  End

  Context '配列名の検証'
    Parameters
      ''
      bad-name
    End

    It '無効な配列名は64を返す'
      When call sx_arr_splice_raw "$1" 1 1 x
      The status should equal 64
      The variable arr should equal "$before_sig"
    End
  End

  It '配列ではない対象は65を返す'
    scalar=value
    When call sx_arr_splice_raw scalar 1 1 x
    The status should equal 65
    The variable scalar should equal value
  End

  Context '配下も含む書込可否'
    Parameters
      arr
      arr_len
      arr_1
      arr_1_nested
    End

    It 'readonly があれば77を返し、何も変更しない'
      readonly "$1"
      When call sx_arr_splice_raw arr 1 1 x
      The status should equal 77
      The variable arr should equal "$before_sig"
      The variable arr_len should equal 3
      The variable arr_1 should equal b
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '必要設定の未設定'
    Parameters
      SX_CFG_SIG_ARR
      SX_CFG_NUM_RANGE
      SX_CFG_ARR_HOLE
    End

    It '変更前に78を返す'
      unset "$1"
      When call sx_arr_splice_raw arr 1 1 x
      The status should equal 78
      The variable arr should equal "$before_sig"
      The variable arr_len should equal 3
      The variable arr_1 should equal b
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '必要設定の不正値'
    Parameters
      SX_CFG_SIG_ARR=
      SX_CFG_NUM_RANGE=invalid
    End

    It '変更前に78を返す'
      export "${1?}"
      When call sx_arr_splice_raw arr 1 1 x
      The status should equal 78
      The variable arr should equal "$before_sig"
      The variable arr_len should equal 3
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It 'SKIP_CHK=1 は設定検査も省略する'
    SX_CFG_SKIP_CHK=1
    SX_CFG_NUM_RANGE=invalid
    When call sx_arr_splice_raw arr 1 1 x
    The status should be success
    The variable arr_len should equal 3
    The variable arr_1 should equal x
    The variable arr should equal "$before_sig"
  End

  Context '整数形式の検証'
    Parameters
      bad 1
      1 bad
      1.5 1
      1 0x1
    End

    It '不正な n または del は64を返す'
      When call sx_arr_splice_raw arr "$1" "$2" x
      The status should equal 64
      The variable arr_len should equal 3
      The variable arr_1 should equal b
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '負数・削除範囲・整数の符号'
    Parameters
      '-1' 1 3 a b x
      1 -1 3 a x c
      '-0' +1 3 x b c
      +1 99 2 a x ''
    End

    It '削除範囲を求め、対象のリビジョンを保持する'
      When call sx_arr_splice_raw arr "$1" "$2" x
      The status should be success
      The variable arr_len should equal "$3"
      The variable arr_0 should equal "$4"
      The variable arr_1 should equal "$5"
      case "$3" in
        2)
          The variable arr_2 should be undefined
          ;;
        *)
          The variable arr_2 should equal "$6"
          ;;
      esac
      case "$3" in
        4)
          The variable arr_3 should equal x
          ;;
      esac
      The variable arr should equal "$before_sig"
    End
  End

  It 'n と del の省略で全要素を削除する'
    When call sx_arr_splice_raw arr
    The status should be success
    The variable arr_len should equal 0
    The variable arr_0 should be undefined
    The variable arr_1 should be undefined
    The variable arr_2 should be undefined
    The variable arr should equal "$before_sig"
  End

  Context '元の座標に基づく削除と先頭側の穴'
    Parameters
      '-3' 0 X a b c
      '-4' 0 X hole a b c
      '-5' 0 X hole hole a b c
      '-5' +0 X hole hole a b c
      '-5' '-0' X hole hole a b c
      '-5' 1 X hole a b c
      '-5' 2 X a b c
      '-5' 3 X b c
      '-5' 99 X
      '-5' '-1' X c
      '-5' '-2' X b c
      '-5' '-3' X a b c
      '-5' '-4' X hole a b c
      '-5' '-5' X hole hole a b c
      '-5' '-6' X hole hole a b c
      '-5' +1 X hole a b c
      '-5' +2 X a b c
      '-5' +3 X b c
      '-5' +99 X
      '-5' '' X
      '' '' X
      '' 1 X b c
      1 0 a X b c
      1 +0 a X b c
      1 '-0' a X b c
      1 '' a X
      2 '-4' a b X c
    End

    It '範囲外の穴も削除数に含め、残った距離を保持する'
      When call sx_arr_splice_raw arr "$1" "$2" X
      The status should be success
      shift 2
      Assert splice_raw_matches "$@"
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '算術幅を超える先頭前の距離と削除範囲の境界'
    Parameters
      9999999999999999999999 X hole a b c
      10000000000000000000000 X a b c
      +10000000000000000000001 X b c
      10000000000000000000003 X
      10000000000000000000004 X
      '-2' X b c
      '-3' X a b c
      '-4' X hole a b c
    End

    It '巨大な距離を保ったまま、残る穴と旧配列の削除範囲を求める'
      When call sx_arr_splice_raw arr -10000000000000000000003 "$1" X
      The status should be success
      shift
      Assert splice_raw_matches "$@"
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '複数要素を先頭より前へ挿入'
    Parameters
      '-3' X Y a b c
      '-4' X Y hole a b c
      '-5' X Y hole hole a b c
    End

    It '挿入数だけ後続をずらしてから全体を平行移動する'
      When call sx_arr_splice_raw arr "$1" 0 X Y
      The status should be success
      shift
      Assert splice_raw_matches "$@"
    End
  End

  Context '挿入値のない範囲外の操作'
    Parameters
      '-5' 0 a b c
      '-5' +0 a b c
      '-5' '-0' a b c
      '-5' 1 a b c
      '-5' 2 a b c
      '-5' 3 b c
      '-5' '-1' c
      '-10000000000000000000000' 1 a b c
      10000 0 a b c
      10000 99 a b c
      10000 '' a b c
    End

    It '削除対象の実要素だけを取り除き、新たな穴は作らない'
      When call sx_arr_splice_raw arr "$1" "$2"
      The status should be success
      shift 2
      Assert splice_raw_matches "$@"
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It '開始位置だけを指定すると、そこから末尾まで削除する'
    When call sx_arr_splice_raw arr 1
    The status should be success
    Assert splice_raw_matches a
    The variable arr_1 should be undefined
    The variable arr_2 should be undefined
  End

  Context '空の削除数で末尾まで削除して挿入'
    Parameters
      0 X Y
      1 a X Y
      2 a b X Y
      '-1' a b X Y
      '-2' a X Y
      '-3' X Y
      '-5' X Y
      '' X Y
      3 a b c X Y
      5 a b c hole hole X Y
    End

    It '先頭前の穴も削除し、縮小・同じ長さ・拡大を区別して置き換える'
      When call sx_arr_splice_raw arr "$1" '' X Y
      The status should be success
      shift
      Assert splice_raw_matches "$@"
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '空の削除数で末尾まで純削除'
    Parameters
      0
      1 a
      2 a b
      '-5'
    End

    It '挿入値がなければ開始位置より前の要素だけを保持する'
      When call sx_arr_splice_raw arr "$1" ''
      The status should be success
      shift
      Assert splice_raw_matches "$@"
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It '末尾までの置換で上書き部分と余剰尾部の入れ子を掃除する'
    sxtest_run arr arr_0 arr_1 arr_1_len arr_1_0 arr_2 arr_2_len arr_2_0 \
      arr_3 arr_3_len arr_3_0 SX_CFG_ARR_HOLE SX_SYS_REV -- \
      'sx_cfg_set ARR_HOLE=hole; sx_arr_gen arr head old old old; sx_arr_gen arr_1 nested1; sx_arr_gen arr_2 nested2; sx_arr_gen arr_3 nested3'
    before_sig=$arr
    before_rev=$SX_SYS_REV
    When call sx_arr_splice_raw arr 1 '' '' hole
    The status should be success
    Assert splice_raw_matches head '' hole
    The variable arr_1_len should be undefined
    The variable arr_1_0 should be undefined
    The variable arr_2_len should be undefined
    The variable arr_2_0 should be undefined
    The variable arr_3 should be undefined
    The variable arr_3_len should be undefined
    The variable arr_3_0 should be undefined
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$before_rev"
  End

  Context '算術幅を超える添字から末尾まで置換'
    Parameters
      10000000000000000000001 10000000000000000000002 10000000000000000000003
      10000000000000000000002 10000000000000000000003 10000000000000000000004
    End

    It '末尾までの距離を求めず、挿入後の終端を長さにする'
      arr_len=10000000000000000000003
      When call sx_arr_splice_raw arr "$1" '' X Y
      The status should be success
      The variable arr_len should equal "$3"
      The variable "arr_${1}" should equal X
      The variable "arr_${2}" should equal Y
      The variable arr_0 should equal a
      The variable arr_1 should equal b
      The variable arr_2 should equal c
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It '巨大な添字からの末尾削除でも余剰要素を掃除する'
    arr_len=10000000000000000000003
    arr_10000000000000000000002=tail
    When call sx_arr_splice_raw arr 10000000000000000000002
    The status should be success
    The variable arr_len should equal 10000000000000000000002
    The variable arr_10000000000000000000002 should be undefined
    The variable arr_0 should equal a
    The variable arr_1 should equal b
    The variable arr_2 should equal c
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$before_rev"
  End

  It '末尾より先では開始位置を保持し、途中を穴にする'
    When call sx_arr_splice_raw arr 10000 0 X Y
    The status should be success
    The variable arr_len should equal 10002
    The variable arr_0 should equal a
    The variable arr_1 should equal b
    The variable arr_2 should equal c
    The variable arr_3 should be undefined
    The variable arr_9999 should be undefined
    The variable arr_10000 should equal X
    The variable arr_10001 should equal Y
  End

  It '旧範囲外への追加でも穴指定以外の値を文字列として保持する'
    sxtest_run source SX_CFG_ARR_HOLE -- '
      source=reference
      sx_cfg_set ARR_HOLE=hole
    '
    When call sx_arr_splice_raw arr 10000 0 hole '' @source literal
    The status should be success
    The variable arr_len should equal 10004
    The variable arr_0 should equal a
    The variable arr_1 should equal b
    The variable arr_2 should equal c
    The variable arr_9999 should be undefined
    The variable arr_10000 should be undefined
    The variable arr_10001 should equal ''
    The variable arr_10002 should equal '@source'
    The variable arr_10003 should equal literal
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$before_rev"
  End

  Context '末尾以降へ穴・空文字・文字列をまとめて追加'
    Parameters
      3 0 7 4 5 6
      3 99 7 4 5 6
      3 '-1' 7 4 5 6
      5 0 9 6 7 8
    End

    It '追加値を区別し、既存の入れ子配列とリビジョンを保持する'
      sxtest_run arr_1 arr_1_len arr_1_0 SX_CFG_ARR_HOLE SX_SYS_REV -- \
        'sx_cfg_set ARR_HOLE=hole; sx_arr_gen arr_1 nested'
      before_rev=$SX_SYS_REV
      When call sx_arr_splice_raw arr "$1" "$2" hole '' @source "it's"
      The status should be success
      The variable arr_len should equal "$3"
      The variable "arr_${1}" should be undefined
      The variable "arr_${4}" should equal ''
      The variable "arr_${5}" should equal '@source'
      The variable "arr_${6}" should equal "it's"
      The variable arr_0 should equal a
      The variable arr_1_len should equal 1
      The variable arr_1_0 should equal nested
      The variable arr_2 should equal c
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '空配列への穴・空文字・文字列の追加'
    Parameters
      0 3 0 1 2
      2 5 2 3 4
      '-2' 3 0 1 2
    End

    It '開始位置を換算し、空文字と穴を区別して追加する'
      sxtest_run arr arr_0 arr_1 arr_2 SX_CFG_ARR_HOLE SX_SYS_REV -- \
        'sx_cfg_set ARR_HOLE=hole; sx_arr_gen arr'
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_splice_raw arr "$1" 0 hole '' "it's"
      The status should be success
      The variable arr_len should equal "$2"
      The variable "arr_${3}" should be undefined
      The variable "arr_${4}" should equal ''
      The variable "arr_${5}" should equal "it's"
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '空配列への挿入'
    Parameters
      0 X Y
      +0 X Y
      '-0' X Y
      2 hole hole X Y
      '-1' X Y
      '-2' X Y
    End

    It '正の開始位置を保持し、負の開始位置でも後ろに穴を残さない'
      sxtest_run arr arr_0 arr_1 arr_2 SX_SYS_REV -- 'sx_arr_gen arr'
      When call sx_arr_splice_raw arr "$1" 0 X Y
      The status should be success
      shift
      Assert splice_raw_matches "$@"
    End
  End

  It '先頭側の新しい穴と旧配列が重なる部分を入れ子まで掃除する'
    sxtest_run arr SX_SYS_REV -- 'sx_arr_gen arr a b c; sx_arr_gen arr_1 nested value'
    When call sx_arr_splice_raw arr -1000 0 X
    The status should be success
    The variable arr_len should equal 1001
    The variable arr_0 should equal X
    The variable arr_1 should be undefined
    The variable arr_1_len should be undefined
    The variable arr_1_0 should be undefined
    The variable arr_1_1 should be undefined
    The variable arr_2 should be undefined
    The variable arr_997 should be undefined
    The variable arr_998 should equal a
    The variable arr_999_len should equal 2
    The variable arr_999_0 should equal nested
    The variable arr_999_1 should equal value
    The variable arr_1000 should equal c
  End

  It '純挿入は空文字と引用符を保持し、尾部を後方へ移動する'
    When call sx_arr_splice_raw arr 1 0 '' "it's"
    The status should be success
    The variable arr_len should equal 5
    The variable arr_0 should equal a
    The variable arr_1 should equal ''
    The variable arr_2 should equal "it's"
    The variable arr_3 should equal b
    The variable arr_4 should equal c
    The variable arr should equal "$before_sig"
  End

  It '入れ子配列の上書きと尾部削除で関連変数を残さない'
    sxtest_run arr SX_CFG_ARR_HOLE SX_SYS_REV -- '
      SX_SYS_REV=$1
      sx_cfg_set ARR_HOLE=hole
      sx_arr_gen arr head old tail
      sx_arr_gen arr_1 nested value
    ' "$SX_SYS_REV"
    nested_sig=$arr
    When call sx_arr_splice_raw arr 1 2 hole
    The status should be success
    The variable arr_len should equal 2
    The variable arr_0 should equal head
    The variable arr_1 should be undefined
    The variable arr_1_len should be undefined
    The variable arr_1_0 should be undefined
    The variable arr_1_1 should be undefined
    The variable arr_2 should be undefined
    The variable arr should equal "$nested_sig"
  End

  It '入れ子配列の名前を含む値も文字列として保存する'
    sxtest_run src SX_SYS_REV -- '
      SX_SYS_REV=$1
      sx_arr_gen src nested value
    ' "$SX_SYS_REV"
    When call sx_arr_splice_raw arr 1 1 @src
    The status should be success
    The variable arr_len should equal 3
    The variable arr_1 should equal '@src'
    The variable arr_1_len should be undefined
    The variable arr_1_0 should be undefined
    The variable arr_1_1 should be undefined
    The variable src_len should equal 2
    The variable src_0 should equal nested
    The variable src_1 should equal value
    The variable arr_2 should equal c
    The variable arr should equal "$before_sig"
  End

  It '削除される要素の参照形式も文字列として挿入する'
    When call sx_arr_splice_raw arr 0 2 '!arr_2'
    The status should be success
    The variable arr_len should equal 2
    The variable arr_0 should equal '!arr_2'
    The variable arr_1 should equal c
    The variable arr_2 should be undefined
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$before_rev"
  End
End
