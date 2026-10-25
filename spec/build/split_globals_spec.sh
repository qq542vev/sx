#!/bin/sh
# shellcheck disable=SC2016 # 子シェルで評価する生成コード。
# shellcheck disable=SC2286,SC2288 # Parameters の値。
eval "$(shellspec - -c) exit 1"
Include ./spec/support/build.sh

Describe '大域変数の個別展開と初期化'
  prepare_globals() {
    build_prepare_project
    LC_ALL=C m4 -- m4/common.m4 src/const.m4 > "$SXTEST_BUILD_DIR/constants.sh"
    LC_ALL=C m4 -- m4/common.m4 src/const.m4 src/var.m4 src/func.m4 > "$SXTEST_BUILD_DIR/full.sh"
    build_unit_paths src/var.m4 > "$SXTEST_BUILD_DIR/listed-paths"
    LC_ALL=C sort "$SXTEST_BUILD_DIR/listed-paths" > "$SXTEST_BUILD_DIR/expected-paths"
    find src/var -type f -name '*.m4' | LC_ALL=C sort > "$SXTEST_BUILD_DIR/actual-paths"
    set --
    while IFS= read -r var_path; do set -- "$@" "$var_path"; done < "$SXTEST_BUILD_DIR/listed-paths"
    LC_ALL=C m4 -- m4/common.m4 "$@" > "$SXTEST_BUILD_DIR/direct.sh"
    LC_ALL=C m4 -- m4/common.m4 src/var.m4 > "$SXTEST_BUILD_DIR/listed.sh"
  }
  # 使用法: globals_probe 展開済みファイル 検証コード [環境の名前=値 ...]
  globals_probe() {
    globals_file=$1
    globals_code=$2
    shift 2
    build_shell_env "$@" ::: '. "$1"; eval "$2"' "$SXTEST_BUILD_DIR/$globals_file" "$globals_code"
  }
  BeforeAll prepare_globals
  AfterAll build_cleanup

  It '大域変数の一覧と実ファイルが一致すること'
    When run cmp "$SXTEST_BUILD_DIR/expected-paths" "$SXTEST_BUILD_DIR/actual-paths"
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It '一覧順の直接展開と一覧ファイルの展開が一致すること'
    When run cmp "$SXTEST_BUILD_DIR/direct.sh" "$SXTEST_BUILD_DIR/listed.sh"
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  Context '各数値派生値は対応する定数だけで初期化できる'
    Parameters:matrix
      32 64 128
      WLEN QM ZR MAX MIN
    End
    It "$1 bit の $2 を単独で初期化できること"
      LC_ALL=C m4 -- m4/common.m4 "src/const/num/SX_NUM_I${1}_${2}.m4" "src/var/sys/SX_SYS_NUM_${2}.m4" > "$SXTEST_BUILD_DIR/numeric.sh"
      expected=$(globals_probe constants.sh "printf '%s' \"\${SX_NUM_I${1}_${2}}\"")
      When run globals_probe numeric.sh "printf '%s' \"\${SX_SYS_NUM_${2}}\"" "SX_CFG_NUM_RANGE=$1"
      The status should be success
      The stdout should equal "$expected"
      The stderr should equal ''
    End
  End

  Context '各設定の単独初期化と変更'
    Parameters:dynamic
      # shellcheck disable=SC2046,SC2013 # 設定項目名を分割し、ケース番号を同じシェルで更新する。
      for name in $(awk -F '[|]' '/^M_UNIT\(/ && $2 ~ /^SX_CFG_/ { print substr($2, 8) }' src/var.m4); do
        for inherited in 未設定 空文字列 特殊文字; do
          %data "$name" "$inherited"
        done
      done
    End
    It "$1 が $2 を保持し、初期化後も変更できること"
      LC_ALL=C m4 -- m4/common.m4 "src/const/cfg/SX_CFG_META_DEF_$1.m4" "src/var/cfg/SX_CFG_$1.m4" > "$SXTEST_BUILD_DIR/config.sh"
      case "$2" in
        未設定)
          expected=$(globals_probe constants.sh "printf '<%s>' \"\${SX_CFG_META_DEF_$1}\"")
          set -- "$1";;
        空文字列)
          expected='<>'
          set -- "$1" "SX_CFG_$1=";;
        *)
          inherited_value='引用'"'"'" $value\
次行'
          expected="<$inherited_value>"
          set -- "$1" "SX_CFG_$1=$inherited_value";;
      esac
      config_name=$1
      shift
      When run globals_probe config.sh "printf '<%s>' \"\${SX_CFG_$config_name}\"; SX_CFG_$config_name=changed; printf '<%s>' \"\${SX_CFG_$config_name}\"" "$@"
      The status should be success
      The stdout should equal "$expected<changed>"
      The stderr should equal ''
    End
  End

  Context '全体版の設定の既定値'
    Parameters:dynamic
      # shellcheck disable=SC2046,SC2013 # 設定項目名を分割し、ケース番号を同じシェルで更新する。
      for name in $(awk -F '[|]' '/^M_UNIT\(/ && $2 ~ /^SX_CFG_/ { print substr($2, 8) }' src/var.m4); do
        %data "$name"
      done
    End
    It "$1 の既定値がメタ情報と一致すること"
      expected=$(globals_probe constants.sh "printf '<%s>' \"\${SX_CFG_META_DEF_$1}\"")
      When run globals_probe full.sh "printf '<%s>' \"\${SX_CFG_$1}\""
      The status should be success
      The stdout should equal "$expected"
      The stderr should equal ''
    End
  End

  It '全体版の初期リビジョンが0であること'
    When run globals_probe full.sh 'printf "%s" "$SX_SYS_REV"'
    The status should be success
    The stdout should equal '0'
    The stderr should equal ''
  End

  It '全体版が設定を環境から継承し、古いシステム状態は初期化すること'
    expected=$(globals_probe constants.sh 'printf "<%s>" "$SX_CFG_META_DEF_SIG_ARR"')
    hole="空白
'\\"
    numeric_expected=$(globals_probe constants.sh 'printf "<%s>" "$SX_NUM_I64_WLEN" "$SX_NUM_I64_QM" "$SX_NUM_I64_ZR" "$SX_NUM_I64_MAX" "$SX_NUM_I64_MIN"')
    When run globals_probe full.sh '
      printf "<%s>" "$SX_CFG_SIG_ARR" "$SX_CFG_SKIP_CHK" "$SX_CFG_NUM_RANGE" "$SX_CFG_SEP" "$SX_CFG_ARR_HOLE" "$SX_CFG_ARR_REF" "$SX_SYS_REV"
      printf "<%s>" "$SX_SYS_NUM_WLEN" "$SX_SYS_NUM_QM" "$SX_SYS_NUM_ZR" "$SX_SYS_NUM_MAX" "$SX_SYS_NUM_MIN"
    ' SX_CFG_SKIP_CHK=1 SX_CFG_NUM_RANGE=64 "SX_CFG_SEP=<> ' $" "SX_CFG_ARR_HOLE=$hole" SX_CFG_ARR_REF= \
      SX_SYS_REV=99 SX_SYS_NUM_WLEN=stale SX_SYS_NUM_QM=stale SX_SYS_NUM_ZR=stale SX_SYS_NUM_MAX=stale SX_SYS_NUM_MIN=stale
    The status should be success
    The stdout should equal "$expected<1><64><<> ' \$><$hole><><0>$numeric_expected"
    The stderr should equal ''
  End

  Context '全体版の数値域の選択'
    Parameters
      32
      64
      128
    End
    It "$1 bit に対応する数値派生値を参照すること"
      expected=$(globals_probe constants.sh "printf '<%s>' \"\${SX_NUM_I${1}_WLEN}\" \"\${SX_NUM_I${1}_QM}\" \"\${SX_NUM_I${1}_ZR}\" \"\${SX_NUM_I${1}_MAX}\" \"\${SX_NUM_I${1}_MIN}\"")
      When run globals_probe full.sh 'printf "<%s>" "$SX_SYS_NUM_WLEN" "$SX_SYS_NUM_QM" "$SX_SYS_NUM_ZR" "$SX_SYS_NUM_MAX" "$SX_SYS_NUM_MIN"' "SX_CFG_NUM_RANGE=$1"
      The status should be success
      The stdout should equal "$expected"
      The stderr should equal ''
    End
  End

  It '数値域の変更ではリビジョンを戻さず、一意名の連番を維持すること'
    expected=$(globals_probe constants.sh 'printf "<%s>" "$SX_NUM_I32_WLEN" "$SX_NUM_I32_QM" "$SX_NUM_I32_ZR" "$SX_NUM_I32_MAX" "$SX_NUM_I32_MIN"')
    When run globals_probe full.sh '
      sx_fn_anon first ":"
      sx_cfg_set NUM_RANGE=32
      printf "<%s>" "$SX_SYS_REV" "$SX_SYS_NUM_WLEN" "$SX_SYS_NUM_QM" "$SX_SYS_NUM_ZR" "$SX_SYS_NUM_MAX" "$SX_SYS_NUM_MIN"
      sx_fn_anon second ":"
      printf "<%s>" "$first" "$second" "$SX_SYS_REV"
    ' SX_CFG_NUM_RANGE=64
    The status should be success
    The stdout should equal "<1>$expected<sx_fn_anon_0><sx_fn_anon_1><2>"
    The stderr should equal ''
  End
End
