# shellcheck shell=sh disable=SC2329
# コールバックは ShellSpec 経由で間接的に呼び出す。

Describe 'sx_csv_parse -efu 環境検証'
  Include ./sx.sh

  Context '公開・内部・検証省略'
    Parameters
      sx_csv_parse 0
      sx_csv_parse 1
      __sx_csv_parse 0
    End

    It '引用内改行と空フィールドを -efu 下で解析できる'
      sx_cfg_set "SKIP_CHK=$2"
      When run efu_run "$1" res "\"a${SX_STR_LF}b\",${SX_STR_LF}"
      The status should be success
    End

    It '引用無効の TSV を -efu 下で解析できる'
      sx_cfg_set "SKIP_CHK=$2"
      When run efu_run "$1" res "a${SX_STR_HT}\"b" '' "$SX_STR_HT" ''
      The status should be success
    End

    It '単独の CR と引用フィールド末尾の CR を -efu 下で解析できる'
      sx_cfg_set "SKIP_CHK=$2"
      When run efu_run "$1" res "${SX_STR_CR},\"a${SX_STR_CR}\"${SX_STR_LF}${SX_STR_CR}"
      The status should be success
    End

    It '異なる引用符と引用内改行を -efu 下で解析できる'
      sx_cfg_set "SKIP_CHK=$2"
      When run efu_run "$1" res "'a\"${SX_STR_LF}b',\"c'd\"" '' ',' "\"'"
      The status should be success
    End

    It '開始時とは別の引用符で閉じようとした場合は -efu 下でもエラーを返す'
      sx_cfg_set "SKIP_CHK=$2"
      When run efu_run "$1" res "\"bad'" '' ',' "\"'"
      The status should equal 1
    End

    It '空の sep でも引用内改行を -efu 下で解析できる'
      sx_cfg_set "SKIP_CHK=$2"
      When run efu_run "$1" res "'a,b${SX_STR_LF}c'${SX_STR_LF}\"d'e\"" '' '' "\"'"
      The status should be success
    End

    It '空の sep と quote でも -efu 下で解析が完了する'
      sx_cfg_set "SKIP_CHK=$2"
      When run efu_run "$1" res "X:a,'b\"${SX_STR_LF}:c,d" '' '' ''
      The status should be success
    End

    It '空の sep でも閉じ引用符の後のカンマを -efu 下で拒否する'
      sx_cfg_set "SKIP_CHK=$2"
      When run efu_run "$1" res '"ok",tail' '' ''
      The status should equal 3
    End

    It '通知コールバックが成功なら -efu 下でも成功を返す'
      sx_cfg_set "SKIP_CHK=$2"
      csv_error() { return 0; }
      When run efu_run "$1" res 'bad"' csv_error
      The status should be success
    End

    It '通知コールバックが失敗なら -efu 下でもその終了ステータスを返す'
      sx_cfg_set "SKIP_CHK=$2"
      csv_error() { return 99; }
      When run efu_run "$1" res 'bad"' csv_error
      The status should equal 99
    End
  End

  Context '構文エラー'
    Parameters
      1 '"bad'
      2 'bad"'
      3 '"bad"x'
    End

    It '内部の構文エラーが -e で中断せず公開関数から伝播する'
      When run efu_run sx_csv_parse res "$2"
      The status should equal "$1"
    End
  End

  It '引数エラーを -efu 下で返す'
    When run efu_run sx_csv_parse res
    The status should equal 64
  End
End
