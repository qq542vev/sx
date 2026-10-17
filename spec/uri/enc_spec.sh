#!/bin/sh
# shellcheck shell=sh
# ShellSpec の引数と参照渡しによる結果変数を検証する。
# shellcheck disable=SC2154,SC2286,SC2329

Describe 'sx_uri_enc'
  Include ./sx.sh

  It '非予約文字をすべて保持する'
    input='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~'
    When call sx_uri_enc res "$input"
    The status should be success
    The variable res should equal "$input"
    The stdout should equal ''
    The stderr should equal ''
  End

  It '変換区間と保持区間を入力順に連結する'
    When call sx_uri_enc res ' a/b?c=d&x=+%20#z!'
    The status should be success
    The variable res should equal '%20a%2Fb%3Fc%3Dd%26x%3D%2B%2520%23z%21'
  End

  It '変換対象だけの入力を処理する'
    When call sx_uri_enc res ' /+%'
    The status should be success
    The variable res should equal '%20%2F%2B%25'
  End

  It '引用符・バックスラッシュ・glob・シェル構文をデータとして扱う'
    # シェル構文は実行させず入力データとして渡す。
    # shellcheck disable=SC2016
    input='$(uri_enc_injected=1);`x`*?[x]"'"'\\"
    When call sx_uri_enc res "$input"
    The status should be success
    The variable res should equal '%24%28uri_enc_injected%3D1%29%3B%60x%60%2A%3F%5Bx%5D%22%27%5C'
    The variable uri_enc_injected should be undefined
  End

  It '改行・タブ・制御文字を変換する'
    When call sx_uri_enc res "${SX_STR_SOH}a${SX_STR_HT}${SX_STR_LF}${SX_STR_CR}z${SX_STR_DEL}"
    The status should be success
    The variable res should equal '%01a%09%0A%0Dz%7F'
  End

  It '空入力で既存結果を空文字列にする'
    res=before
    When call sx_uri_enc res ''
    The status should be success
    The variable res should equal ''
  End

  It '入力を格納した変数へ結果を上書きできる'
    res='a b%'
    When call sx_uri_enc res "$res"
    The status should be success
    The variable res should equal 'a%20b%25'
  End

  It '数値範囲設定に依存しない'
    SX_CFG_NUM_RANGE=invalid
    When call sx_uri_enc res 'a/b'
    The status should be success
    The variable res should equal 'a%2Fb'
  End

  Context '公開・内部・検証省略'
    Parameters
      sx_uri_enc 0
      sx_uri_enc 1
      __sx_uri_enc 0
    End

    It '各経路で入力省略を空文字列として扱う'
      SX_CFG_SKIP_CHK=$2
      res=before
      When call "$1" res
      The status should be success
      The variable res should equal ''
    End

    It '各経路で同じ結果を返す'
      SX_CFG_SKIP_CHK=$2
      When call "$1" res '%a b/'
      The status should be success
      The variable res should equal '%25a%20b%2F'
    End
  End

  Context '引数検証'
    Parameters
      ''
      '1invalid'
      'invalid-name'
      'res:other'
      'res;command'
    End

    It '不正な結果変数名を拒否する'
      When call sx_uri_enc "$1" value
      The status should equal 64
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '結果変数名の省略を拒否する'
    When call sx_uri_enc
    The status should equal 64
  End

  It '余分な引数を拒否し結果を変更しない'
    res=before
    When call sx_uri_enc res input extra
    The status should equal 64
    The variable res should equal before
  End

  It '読み取り専用の結果変数を拒否し値を保持する'
    readonly res=before
    When call sx_uri_enc res input
    The status should equal 77
    The variable res should equal before
    The stderr should equal ''
  End

  Context 'C ロケールでの任意バイト列'
    # Yash は任意バイト列を保持できないため、この区分の対象から除外する。
    Skip if 'Yash は任意バイト列を保持できない' [ "$SHELLSPEC_SHELL_TYPE" = yash ]
    Skip if 'C ロケールで起動する必要がある' [ "${LC_ALL-${LC_CTYPE-${LANG-}}}" != C ]

    It 'UTF-8 のバイト列を文字コード変換せずエンコードする'
      input=$(printf '\343\201\202\343\201\204\343\201\206abc\360\237\230\200')
      When call sx_uri_enc res "$input"
      The status should be success
      The variable res should equal '%E3%81%82%E3%81%84%E3%81%86abc%F0%9F%98%80'
    End

    It 'UTF-8 として不正なバイトもそのままエンコードする'
      input=$(printf '\377a\200\300\257')
      When call sx_uri_enc res "$input"
      The status should be success
      The variable res should equal '%FFa%80%C0%AF'
    End

    It '全255個の非 NUL バイトを printf による期待値と照合する'
      input='' expected='' byte_value=1
      while [ "$byte_value" -le 255 ]; do
        octal=$(printf '%03o' "$byte_value")
        # 改行バイトもコマンド置換で消えないよう末尾に印を置く。
        byte=$(printf '%b.' "\\$octal")
        byte=${byte%.}
        input=$input$byte
        case "$byte_value" in
          45 | 46 | 48 | 49 | 5[0-7] | 6[5-9] | [78][0-9] | 90 | 95 | 9[7-9] | 1[01][0-9] | 12[0-2] | 126)
            expected=$expected$byte
            ;;
          *) expected=$expected$(printf '%%%02X' "$byte_value");;
        esac
        byte_value=$((byte_value + 1))
      done
      When call sx_uri_enc res "$input"
      The status should be success
      The variable res should equal "$expected"
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
