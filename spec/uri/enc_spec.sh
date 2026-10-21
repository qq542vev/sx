#!/bin/sh
# shellcheck shell=sh
# ShellSpec の引数と参照渡しによる結果変数を検証する。
# shellcheck disable=SC2154,SC2286,SC2329

Describe 'sx_uri_enc'
  Include ./spec/support/library.sh sx_uri_enc

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
    input=$(printf '\001a\011\012\015z\177')
    When call sx_uri_enc res "$input"
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

  It '数値範囲設定が不正なら結果を変更せず拒否する'
    res=before
    SX_CFG_NUM_RANGE=invalid
    When call sx_uri_enc res 'a/b'
    The status should equal 78
    The variable res should equal before
  End

  It '複数入力をクォートせず空白区切りで蓄積する'
    When call sx_uri_enc res 'a b' 'c/d' '%20'
    The status should be success
    The variable res should equal 'a%20b c%2Fd %2520'
  End

  It '分配スロットへ順番に代入して残りを蓄積する'
    When call sx_uri_enc 'item_a:item_b:rest' 'a b' 'c/d' 'x+y' 'z%'
    The status should be success
    The variable item_a should equal 'a%20b'
    The variable item_b should equal 'c%2Fd'
    The variable rest should equal 'x%2By z%25'
  End

  It '数値プレフィックスの蓄積先へ指定件数を渡す'
    When call sx_uri_enc '2group:rest' 'a b' 'c/d' 'x+y' 'z%'
    The status should be success
    The variable group should equal 'a%20b c%2Fd'
    The variable rest should equal 'x%2By z%25'
  End

  It '空スロットと件数指定で入力をスキップする'
    When call sx_uri_enc 'item_a::2:rest' a ignored skip skip 'b c'
    The status should be success
    The variable item_a should equal a
    The variable rest should equal 'b%20c'
  End

  It 'バインド枯渇後の余分な入力を破棄して成功する'
    When call sx_uri_enc 'item_a:item_b:' 'a b' 'c/d' ignored extra
    The status should be success
    The variable item_a should equal 'a%20b'
    The variable item_b should equal 'c%2Fd'
  End

  It '空のバインド形式はすべての入力を破棄する'
    res=before
    When call sx_uri_enc '' 'a b' extra
    The status should be success
    The variable res should equal before
  End

  It '入力なしでは代入スロットを unset し蓄積先を空にする'
    item_a=before rest=before
    When call sx_uri_enc 'item_a:rest'
    The status should be success
    The variable item_a should be undefined
    The variable rest should equal ''
  End

  It '空文字列を代入スロットへ渡し未到達のスロットと区別する'
    item_a=before item_b=before
    When call sx_uri_enc 'item_a:item_b:' ''
    The status should be success
    The variable item_a should equal ''
    The variable item_b should be undefined
  End

  It '入力が少なくても数値プレフィックスの蓄積先を初期化する'
    group=before rest=before
    When call sx_uri_enc '2group:rest' 'a b'
    The status should be success
    The variable group should equal 'a%20b'
    The variable rest should equal ''
  End

  It '蓄積先の先頭の空文字列は既存の ubind と同じ扱いにする'
    When call sx_uri_enc res '' 'a b'
    The status should be success
    The variable res should equal 'a%20b'
  End

  It '蓄積先の途中の空文字列は ubind の区切り規則に従う'
    When call sx_uri_enc res a '' b
    The status should be success
    The variable res should equal 'a  b'
  End

  It '配列に空文字列を含むすべての結果を保存する'
    When call sx_uri_enc '@res' 'a b' '' 'c/d'
    The status should be success
    The variable res_len should equal 3
    The variable res_0 should equal 'a%20b'
    The variable res_1 should equal ''
    The variable res_2 should equal 'c%2Fd'
    The variable res should start with "${SX_CFG_SIG_ARR}:"
  End

  It '既存配列の関連変数を解放してからバインド先として再利用する'
    res="${SX_CFG_SIG_ARR}:0" res_len=3
    res_0=old res_1=old res_2=old
    unset res res_len res_0 res_1 res_2
    When call sx_uri_enc '@res' 'a b'
    The status should be success
    The variable res_len should equal 1
    The variable res_0 should equal 'a%20b'
    The variable res_1 should be undefined
    The variable res_2 should be undefined
  End

  It '入力なしの配列バインドは空配列にする'
    When call sx_uri_enc '@res'
    The status should be success
    The variable res_len should equal 0
    The variable res should start with "${SX_CFG_SIG_ARR}:"
  End

  It '数値プレフィックス付き配列と後続スロットへ分配する'
    When call sx_uri_enc 'item_a:2@items:rest' 'a b' '' 'c/d' 'e+f'
    The status should be success
    The variable item_a should equal 'a%20b'
    The variable items_len should equal 2
    The variable items_0 should equal ''
    The variable items_1 should equal 'c%2Fd'
    The variable rest should equal 'e%2Bf'
  End

  It '未使用の配列スロットも先に初期化する'
    When call sx_uri_enc 'item_a:@items' a
    The status should be success
    The variable item_a should equal a
    The variable items_len should equal 0
  End

  Context '公開・内部・検証省略'
    Parameters
      sx_uri_enc 0
      sx_uri_enc 1
      __sx_uri_enc 0
    End

    It '各経路で入力省略を 0 件として扱う'
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

    It '各経路で分配・配列・蓄積を組み合わせられる'
      SX_CFG_SKIP_CHK=$2
      When call "$1" 'item_a:2@items:rest' 'a b' '' 'c/d' 'x+y' 'z%'
      The status should be success
      The variable item_a should equal 'a%20b'
      The variable items_len should equal 2
      The variable items_0 should equal ''
      The variable items_1 should equal 'c%2Fd'
      The variable rest should equal 'x%2By z%25'
    End

    It '各経路でバインドが枯渇しても成功する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" 'item_a:' 'a b' 'c/d'
      The status should be success
      The variable item_a should equal 'a%20b'
    End
  End

  Context '引数検証'
    Parameters
      '1invalid'
      'invalid-name'
      'res;command'
      '0res:other'
      '2res'
      'res:res'
      'res:@res'
    End

    It '不正なバインド形式を拒否する'
      When call sx_uri_enc "$1" value
      The status should equal 64
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It 'バインド形式の省略を拒否する'
    When call sx_uri_enc
    The status should equal 64
  End

  It '読み取り専用の結果変数を拒否し値を保持する'
    readonly res=before
    When call sx_uri_enc res input
    The status should equal 77
    The variable res should equal before
    The stderr should equal ''
  End

  It '後続スロットが読み取り専用なら先頭も変更しない'
    item_a=before
    readonly item_b=before
    When call sx_uri_enc 'item_a:item_b:' a b
    The status should equal 77
    The variable item_a should equal before
    The variable item_b should equal before
  End

  It '配列要素が読み取り専用なら初期化前に拒否する'
    res="${SX_CFG_SIG_ARR}:0" res_len=1 res_0=old
    readonly res_0
    When call sx_uri_enc '@res' 'a b'
    The status should equal 77
    The variable res_len should equal 1
    The variable res_0 should equal old
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
