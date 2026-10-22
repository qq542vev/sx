#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '命名規則・タイトルケース変換の多倍長対応'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_str_words)
        Include ./spec/support/library.sh sx_str_words
        ;;
      sx_str_title)
        Include ./spec/support/library.sh sx_str_title
        ;;
      sx_str_camel)
        Include ./spec/support/library.sh sx_str_camel
        ;;
      sx_str_pascal)
        Include ./spec/support/library.sh sx_str_pascal
        ;;
      __sx_str_words)
        Include ./spec/support/library.sh __sx_str_words
        ;;
      __sx_str_title)
        Include ./spec/support/library.sh __sx_str_title
        ;;
      __sx_str_camel)
        Include ./spec/support/library.sh __sx_str_camel
        ;;
      __sx_str_pascal)
        Include ./spec/support/library.sh __sx_str_pascal
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/prepare.sh

  Context '公開APIの文字列長制限撤廃'
    Parameters
      sx_str_words 0 'xml parser'
      sx_str_words 1 'xml parser'
      sx_str_title 0 Xmlparser
      sx_str_title 1 Xmlparser
      sx_str_camel 0 xmlParser
      sx_str_camel 1 xmlParser
      sx_str_pascal 0 XmlParser
      sx_str_pascal 1 XmlParser
    End

    It '検査の有無によらず文字列長を安全範囲で拒否しないこと'
      load_subject "$1"
      __sx_num_is_nat0_safe() { return 1; }
      sx_test_setup sx_cfg_set "SKIP_CHK=$2"
      When call "$1" res XMLParser
      The status should be success
      The variable res should equal "$3"
    End
  End

  Context '短い入力で多倍長経路を強制'
    Parameters
      sx_str_words 0 'xml parser'
      sx_str_words 1 'xml parser'
      sx_str_title 0 Xmlparser
      sx_str_title 1 Xmlparser
      sx_str_camel 0 xmlParser
      sx_str_camel 1 xmlParser
      sx_str_pascal 0 XmlParser
      sx_str_pascal 1 XmlParser
    End

    It '中間文字列を含め多倍長の回数・位置演算で変換すること'
      load_subject "$1"
      # 入力と中間文字列の長さだけを範囲外とし、下位演算の実装は維持する。
      __sx_num_is_int_fit_dec() {
        case "${#}:${2-}" in
          2:9 | 2:10 | 2:11 | 2:12 | 5:9 | 5:10 | 5:11 | 5:12) return 1;;
        esac
        return 0
      }
      __sx_num_add1_arith() { return 64; }
      sx_test_setup sx_cfg_set "SKIP_CHK=$2"
      When call "$1" res XMLParser
      The status should be success
      The variable res should equal "$3"
    End
  End

  Context '8bit範囲の最大文字列長の前後'
    Parameters
      __sx_str_words 126
      __sx_str_words 127
      __sx_str_words 128
      __sx_str_title 126
      __sx_str_title 127
      __sx_str_title 128
      __sx_str_camel 126
      __sx_str_camel 127
      __sx_str_camel 128
      __sx_str_pascal 126
      __sx_str_pascal 127
      __sx_str_pascal 128
    End

    It '前置文字や単語境界を加えた中間文字列も処理できること'
      load_subject "$1"
      str='' expected=''
      sx_test_setup sx_str_rep str A "$2"
      sx_test_setup sx_str_rep expected a "$2"
      case "$1" in
        __sx_str_title | __sx_str_pascal) expected="A${expected#?}";;
      esac
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      sx_test_setup __sx_cfg_set NUM_RANGE=8
      When call "$1" res "$str"
      The status should be success
      The variable res should equal "$expected"
    End
  End

  Context '8bit範囲の最大変換回数の前後'
    Parameters
      __sx_str_words 126
      __sx_str_words 127
      __sx_str_words 128
      __sx_str_title 126
      __sx_str_title 127
      __sx_str_title 128
      __sx_str_camel 126
      __sx_str_camel 127
      __sx_str_camel 128
      __sx_str_pascal 126
      __sx_str_pascal 127
      __sx_str_pascal 128
    End

    It '全単語を変換して回数カウンタの境界を越えられること'
      load_subject "$1"
      str='' expected=''
      case "$1" in
        __sx_str_words | __sx_str_title) sx_test_setup sx_str_rep str aB_ "$2";;
        *) sx_test_setup sx_str_rep str A_ "$2";;
      esac
      case "$1" in
        __sx_str_words)
          sx_test_setup sx_str_rep expected 'a b ' "$2"
          expected="${expected% }"
          ;;
        __sx_str_title) sx_test_setup sx_str_rep expected Ab_ "$2";;
        __sx_str_camel)
          sx_test_setup sx_str_rep expected A "$2"
          expected="a${expected#?}"
          ;;
        __sx_str_pascal) sx_test_setup sx_str_rep expected A "$2";;
      esac
      sx_test_setup __sx_cfg_set NUM_RANGE=8
      case "$1" in
        __sx_str_title) set -- "$1" res "$str" _;;
        *) set -- "$1" res "$str";;
      esac
      When call "$@"
      The status should be success
      The variable res should equal "$expected"
    End
  End

  It 'title は両段階を固定上限なしで委譲しコールバック用フラグを保持すること'
    load_subject sx_str_title
    # 巨大な実文字列を生成せず、下位APIに渡す回数制限を検証する。
    # ! だけの区切り文字セットは glob_bracket から直接返される。
    __sx_str_tr() {
      lower_limit="${5-}"
      sx_test_setup sx_var_set "${1%%:*}=abc!def"
    }
    __sx_str_sub() {
      title_limit="${5-}"
      title_flags="${6-}"
      sx_test_setup sx_var_set "${1%%:*}=!Abc!Def"
    }
    When call sx_str_title res ABC!DEF '!'
    The status should be success
    The variable res should equal Abc!Def
    The variable lower_limit should equal ''
    The variable title_limit should equal ''
    The variable title_flags should equal "$((1 | 2))"
  End

  Context '設定不正の検証'
    Parameters
      sx_str_words
      sx_str_title
      sx_str_camel
      sx_str_pascal
    End

    It '長さ制限撤廃後も設定不正を78で拒否し結果を変更しないこと'
      load_subject "$1"
      res=original
      # 不正な環境設定を模擬するため、検証を通る設定関数は使用しない。
      SX_CFG_NUM_RANGE=invalid
      When call "$1" res XMLParser
      The status should equal 78
      The variable res should equal original
    End
  End

  It 'title は不正な結果変数名を64で拒否すること'
    load_subject sx_str_title
    When call sx_str_title 1invalid XMLParser
    The status should equal 64
  End
End
