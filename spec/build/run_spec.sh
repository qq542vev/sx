# shellcheck shell=sh
# 準備用コードの展開は子シェルで行い、参照渡しの結果を検査する。
# shellcheck disable=SC2016,SC2154
# Parameters 内の空文字・コード文字列はコマンド名ではない。
# shellcheck disable=SC2286,SC2288

Describe 'sxtest_run による補助処理の実行'
  Include ./spec/support/run.sh

  It '複数の準備処理を同じシェルで実行し、指定した出力だけを戻すこと'
    kept=parent
    setup_command='
      sx_arr_gen items a b
      sx_arr_push items c
      result=ready
      kept=child
      not_requested=child
    '
    When call sxtest_run items result -- "$setup_command"
    The status should be success
    The variable items_len should equal 3
    The variable items_2 should equal c
    The variable result should equal ready
    The variable kept should equal parent
    The variable not_requested should be undefined
    The variable SX_SYS_REV should be undefined
    The variable SXTEST_RUN_NAMES should be undefined
    The variable SXTEST_RUN_SCRIPT should be undefined
  End

  It '位置パラメータの空白・空文字・引用符・末尾改行・globを保持すること'
    tail='first
last
'
    When call sxtest_run items -- 'sx_arr_gen items "$@"' 'a b' '' "it's" "$tail" '* ?'
    The status should be success
    The variable items_len should equal 5
    The variable items_0 should equal 'a b'
    The variable items_1 should equal ''
    The variable items_2 should equal "it's"
    The variable items_3 should equal "$tail"
    The variable items_4 should equal '* ?'
  End

  It '入れ子と疎配列の構造を戻すこと'
    setup_command='
      sx_arr_gen items a b c
      unset items_1
      sx_arr_gen items_2 nested ""
    '
    When call sxtest_run items -- "$setup_command"
    The status should be success
    The variable items_len should equal 3
    The variable items_1 should be undefined
    The variable items_2_len should equal 2
    The variable items_2_0 should equal nested
    The variable items_2_1 should equal ''
  End

  It '明示的にexportした疎配列を子で利用しても穴を保持すること'
    sxtest_run items -- 'sx_arr_gen items a b c; unset items_1'
    export items items_len items_0 items_2

    When call sxtest_run encoded items SX_CFG_ARR_HOLE= -- 'sx_arr_quote encoded items'
    The status should be success
    The variable encoded should equal "'a' '' 'c'"
    The variable items_len should equal 3
    The variable items_0 should equal a
    The variable items_1 should be undefined
    The variable items_2 should equal c
    The stdout should equal ''
    The stderr should equal ''
  End

  It '親の一般変数・配列・設定・リビジョンを自動転送しないこと'
    unset only_parent parent_items parent_items_len parent_items_0 SX_CFG_ARR_HOLE SX_SYS_REV
    only_parent=parent
    parent_items=parent
    parent_items_len=1
    parent_items_0=value
    SX_CFG_ARR_HOLE=parent_hole
    SX_SYS_REV=123
    setup_command='
      case ${only_parent+X}${parent_items+X}${parent_items_len+X}${parent_items_0+X} in
        "") ;;
        *) exit 65;;
      esac
      case $SX_CFG_ARR_HOLE:$SX_SYS_REV in :0) ;; *) exit 65;; esac
      observed=isolated
    '
    When call sxtest_run observed -- "$setup_command"
    The status should be success
    The variable observed should equal isolated
    The variable SX_CFG_ARR_HOLE should equal parent_hole
    The variable SX_SYS_REV should equal 123
  End

  It 'export済みの環境変数は通常どおり継承すること'
    export SXT_ENV_INPUT='space quote'
    When call sxtest_run observed -- 'observed=$SXT_ENV_INPUT'
    The status should be success
    The variable observed should equal 'space quote'
  End

  It '出力名と混在する環境変数指定と位置引数を子へ渡し、親の入力は変更しないこと'
    export SXT_ENV_INPUT=parent
    When call sxtest_run observed 'SXT_ENV_INPUT=child value' args -- 'observed=$SXT_ENV_INPUT; args="$#:$1:$2"' 'a b' ''
    The status should be success
    The variable observed should equal 'child value'
    The variable args should equal '2:a b:'
    The variable SXT_ENV_INPUT should equal parent
  End

  It '親のIFSが変更されていてもシェルの起動オプションを分割できること'
    run_with_ifs() (
      IFS=:
      SHELLSPEC_SHELL="${SHELLSPEC_SHELL} -f"
      sxtest_run observed -- 'observed=$1' 'a b'
      [ "$IFS" = : ] || return 1
      printf '%s' "$observed"
    )
    When call run_with_ifs
    The status should be success
    The stdout should equal 'a b'
  End

  It '設定とリビジョンを引数で渡し、明示した状態だけを戻すこと'
    SX_SYS_REV=7
    setup_command='
      SX_SYS_REV=$1
      shift
      sx_cfg_set ARR_HOLE=hole
      sx_arr_gen items "$@"
    '
    When call sxtest_run items SX_SYS_REV -- "$setup_command" "$SX_SYS_REV" a b
    The status should be success
    The variable items should end with ':7'
    The variable SX_SYS_REV should equal 8
    The variable SX_CFG_ARR_HOLE should be undefined
    The variable SX_SYS_NUM_WLEN should be undefined
  End

  It '出力0個でもCMDを実行し、表示を標準エラーへ送ること'
    When call sxtest_run -- 'printf "%s\n" executed; hidden=child'
    The status should be success
    The stdout should equal ''
    The stderr should equal executed
    The variable hidden should be undefined
  End

  It '空CMDを受け付け、出力0個でも成功すること'
    When call sxtest_run -- ''
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The variable SXTEST_RUN_SCRIPT should be undefined
  End

  It 'CMDの標準出力を復元コードと混在させないこと'
    setup_command='
      printf "%s\n" "not shell code"
      printf "%s\n" diagnostic >&2
      result=ready
    '
    When call sxtest_run result -- "$setup_command"
    The status should be success
    The stdout should equal ''
    The stderr should equal 'not shell code
diagnostic'
    The variable result should equal ready
  End

  It 'CMDが位置パラメータとIFSを変更しても出力先を保持すること'
    setup_command='
      set -- replaced
      IFS=:
      out_first=$1
      out_second=value
    '
    When call sxtest_run out_first out_second -- "$setup_command" original
    The status should be success
    The variable out_first should equal replaced
    The variable out_second should equal value
  End

  It '未設定の出力は親側でもunsetすること'
    result=old
    When call sxtest_run result -- ':'
    The status should be success
    The variable result should be undefined
  End

  It '削除した配列の構成変数を明示すると親側からも削除すること'
    sxtest_run items -- 'sx_arr_gen items a b c'
    setup_command='
      sx_arr_gen items a b c
      sx_var_unset items
    '

    When call sxtest_run items items_len items_0 items_1 items_2 -- "$setup_command"
    The status should be success
    The variable items should be undefined
    The variable items_len should be undefined
    The variable items_0 should be undefined
    The variable items_1 should be undefined
    The variable items_2 should be undefined
    The stdout should equal ''
    The stderr should equal ''
  End

  Context '準備・ダンプの失敗'
    Parameters
      'result=changed; exit 23' 23
      'result=changed; false; result=unreachable' 1
      'result=changed; false | :; result=unreachable' 1
      'result=changed; : "$SXT_UNSET_INPUT"' 2
      'result=changed; __sx_var_dump() { return 65; }' 65
      'result=changed; readonly SXTEST_RUN_DUMP' 77
    End

    It '失敗状態を返し、親の値を変更しないこと'
      unset SXT_UNSET_INPUT
      result=parent
      When call sxtest_run result -- "$1"
      The status should equal "$2"
      The stdout should equal ''
      case "$2" in
        2)
          The stderr should include SXT_UNSET_INPUT
          ;;
      esac
      The variable result should equal parent
      The variable SXTEST_RUN_NAMES should be undefined
      The variable SXTEST_RUN_SCRIPT should be undefined
    End
  End

  It '内部境界試験用の設定値を公開APIで再検査せず復元すること'
    When call sxtest_run SX_CFG_NUM_RANGE -- '__sx_cfg_set NUM_RANGE=8'
    The status should be success
    The variable SX_CFG_NUM_RANGE should equal 8
    The stdout should equal ''
    The stderr should equal ''
  End

  It '出力0個でもCMDの失敗状態を返すこと'
    When call sxtest_run -- 'exit 29'
    The status should equal 29
    The stdout should equal ''
    The stderr should equal ''
  End

  It '準備側でパス名展開を無効にすること'
    When call sxtest_run observed -- 'set -- *; observed=$1'
    The status should be success
    The variable observed should equal '*'
  End

  Context '呼出形式の検査'
    Parameters
      ""
      "result"
      "result --"
      "'' -- ':'"
      "1invalid -- ':'"
      "a:b -- ':'"
      "'a b' -- ':'"
      "SXTEST_RUN_SCRIPT -- ':'"
      "SXTEST_USER -- ':'"
      "'x;bad' -- ':'"
    End

    invalid_run() {
      eval "sxtest_run $1"
    }

    It '不正な構文・変数名を64で拒否すること'
      When call invalid_run "$1"
      The status should equal 64
      The stdout should equal ''
      The stderr should equal ''
      The variable SXTEST_RUN_NAMES should be undefined
      The variable SXTEST_RUN_SCRIPT should be undefined
    End
  End

  It '変数名が不正ならCMDを実行しないこと'
    When call sxtest_run 'bad:name' -- 'printf "%s\n" must_not_run'
    The status should equal 64
    The stdout should equal ''
    The stderr should equal ''
  End

  It '準備側のライブラリ関数を親に定義しないこと'
    sxtest_run items -- 'sx_arr_gen items a'
    When call command -v sx_arr_gen
    The status should be failure
    The stdout should equal ''
    The stderr should equal ''
  End
End

Describe 'sxtest_run と単独モジュールの組み合わせ'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_arr_splice.sh

  It '準備した配列を検証側の対象関数へ渡せること'
    sxtest_run items -- 'sx_arr_gen items "$@"' a b c
    When call sx_arr_splice items 1 1 x
    The status should be success
    The variable items_len should equal 3
    The variable items_0 should equal a
    The variable items_1 should equal x
    The variable items_2 should equal c
  End
End
