#!/bin/sh
# shellcheck shell=sh

Describe 'sx_uri_is_enc'
  sxtest_load ./build/modules/sx_uri_is_enc.sh

  Context '公開・内部・検証省略'
    Parameters
      sx_uri_is_enc 0
      sx_uri_is_enc 1
      __sx_uri_is_enc 0
    End

    It '入力なしは成功する'
      SX_CFG_SKIP_CHK=$2
      When call "$1"
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It '空文字列を複数渡しても成功する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '' '' ''
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It 'すべての非予約文字を許可する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It '大小混在の16進数字と連続する表記を許可する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%41%4a%4A%ff%FF' 'abc%20def' '%01%09%0a%0D%7f'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It 'UTF-8 のパーセント表記を許可する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%E3%81%82%E3%81%84%E3%81%86abc'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It '文字コードの妥当性は検査しない'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%FF%FE%C0%AF'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It '再帰的にデコードせず NUL の二重表記を許可する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%2500' 'a%2500b' '%25%30%30'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It 'エンコード済みの予約文字を許可する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%2f%3F%23%26%3d%2B%25'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な表記 % を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な表記 %0 を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%0'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な表記 %G0 を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%G0'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な表記 %0G を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%0G'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な表記 %gg を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%gg'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な表記 %%20 を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%%20'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な表記 %2%30 を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%2%30'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な表記 %41% を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%41%'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な表記 %41%4 を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%41%4'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な表記 %41%GG を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%41%GG'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '不正な表記 a%20b%2Gz を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" 'a%20b%2Gz'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '日本語を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" 'あいうabc'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '予約文字を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" ':/?#[]@!$&'"'"'()*+,;='
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '空白を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" 'a b'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '改行と制御文字を拒否する'
      SX_CFG_SKIP_CHK=$2
      input=$(printf 'a\012\011\001b')
      When call "$1" "$input"
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '非 ASCII の16進数字に似た文字を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '１２ＡＦ'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It 'バックスラッシュと globを拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '\*?[x]'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '生の文字とパーセント表記の混在を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" 'あ%20い/う'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '%00 を許可する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%00'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It 'a%00b を許可する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" 'a%00b'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It '%00%41 を許可する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%00%41'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It '%41%00 を許可する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%41%00'
      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End

    It '複数引数の先頭にある不正な表記を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" '%' 'abc' '%20'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '複数引数の途中にある不正な表記を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" 'abc' '%' '%20'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '複数引数の末尾にある不正な表記を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" 'abc' '%20' '%'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

    It '複数引数の途中にある生の予約文字を拒否する'
      SX_CFG_SKIP_CHK=$2
      When call "$1" 'abc' '/' '%20'
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End

  End

  It '設定の数値範囲や検証省略の未設定に依存しない'
    SX_CFG_NUM_RANGE=invalid
    unset SX_CFG_SKIP_CHK
    When call sx_uri_is_enc 'abc%20def'
    The status should be success
  End

  It '連続した呼び出しで失敗後も成功し、リビジョンを変更しない'
    # 判定関数に不要なカウンタは、非変更を検査する初期値をテスト側で用意する。
    SX_SYS_REV=41
    # shellcheck disable=SC2329
    check_repeated() {
      if sx_uri_is_enc '%GG'; then return 1; fi
      sx_uri_is_enc 'abc%20def' || return
      if sx_uri_is_enc '%'; then return 1; fi
      sx_uri_is_enc ''
    }
    When call check_repeated
    The status should be success
    The variable SX_SYS_REV should equal 41
  End
End
