# shellcheck shell=sh

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

  It '通知コールバックの失敗でパースエラーが変わらない'
    csv_error() { return 99; }
    When run efu_run sx_csv_parse res 'bad"' csv_error
    The status should equal 2
  End

  It '引数エラーを -efu 下で返す'
    When run efu_run sx_csv_parse res
    The status should equal 64
  End
End
