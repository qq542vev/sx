#!/usr/bin/make -f

### Script: Makefile
##
## ファイルを作成する。
##
## Metadata:
##
##   id - 326bc7e4-b84e-480e-b860-48cc5b1ef4b7
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   created - 2026-05-08
##   modified - 2026-05-08
##   copyright - Copyright (C) 2026-2026 qq542vev. All rights reserved.
##   license - <GPL-3.0-only at https://www.gnu.org/licenses/gpl-3.0.txt>
##   depends - awk, chmod, echo, m4, mkdir, mv, rm, shellspec
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/sx>
##   * <Bag report at https://github.com/qq542vev/sx/issues>

# Sp Targets
# ==========

.POSIX:

.PHONY: all bundle modules test clean rebuild help version

.SILENT: help version

# Macro
# =====

VERSION = 0.0.1

COMPACT = tools/compact.awk

# Build
# =====

all: bundle

# SX_SYMBOLS と SX_OUT は make のコマンド行で指定できる。
# 選択内容と出力先が変わっても反映されるよう、毎回生成する。
bundle:
	@set -eu; \
	symbols=$${SX_SYMBOLS-}; \
	out=$${SX_OUT:-sx.sh}; \
	case "$$out" in */*) dir=$${out%/*}; case "$$dir" in '') dir=/;; esac; mkdir -p -- "$$dir";; esac; \
	raw="$$out.tmp"; compact="$$out.tmp2"; \
	trap 'rm -f -- "$$raw" "$$compact"' 0; \
	m4 "-DSX_SYMBOLS=$$symbols" -- m4/resolve.m4 > "$$raw"; \
	LC_ALL=C awk -f $(COMPACT) "$$raw" > "$$compact"; \
	chmod 755 -- "$$compact"; \
	mv -f -- "$$compact" "$$out"

# 指定名ごとに依存先を含め、単独で読み込めるファイルを作成する。
modules:
	@set -efu; \
	symbols=$${SX_SYMBOLS-}; \
	case "$$symbols" in '') echo 'modules には SX_SYMBOLS を指定してください' >&2; exit 1;; esac; \
	case "$$symbols" in *[!A-Za-z0-9_\ ]*|' '*|*' '|*'  '*) echo 'SX_SYMBOLS の形式が不正です' >&2; exit 1;; esac; \
	IFS=' '; \
	for symbol in $$symbols; do \
		case "$$symbol" in [0-9]*) echo 'SX_SYMBOLS の形式が不正です' >&2; exit 1;; esac; \
	done; \
	for symbol in $$symbols; do \
		$(MAKE) SX_SYMBOLS="$$symbol" SX_OUT="build/modules/$$symbol.sh" bundle; \
	done

# Test
# ====

test:
	$(MAKE) SX_SYMBOLS= SX_OUT=sx.sh all
	$(MAKE) SX_SYMBOLS=sx_uri_enc modules
	SX_TEST_MODE=full shellspec
	SX_TEST_MODE=module shellspec spec/uri/enc_spec.sh spec/efu/uri/sx_uri_enc_spec.sh

# Clean
# =====

clean:
	rm -f -- sx.sh sx.sh.tmp sx.sh.tmp2
	rm -f -- build/modules/*.sh build/modules/*.sh.tmp build/modules/*.sh.tmp2

rebuild: clean
	$(MAKE)

# Message
# =======

help:
	echo 'ファイルを作成する。'
	echo
	echo 'USAGE:'
	echo '  make [OPTION...] [MACRO=VALUE...] [TARGET...]'
	echo
	echo 'TARGET:'
	echo '  all     SX_SYMBOLS が空なら全機能、指定時はその名前と依存先を生成する。'
	echo '          出力先は SX_OUT（既定 sx.sh）で指定できる。'
	echo '          例: make SX_SYMBOLS=sx_uri_enc SX_OUT=sx-uri-enc.sh'
	echo '  bundle  all と同じ生成処理を実行する。'
	echo '  modules SX_SYMBOLS の各指定名を build/modules/<名前>.sh に個別生成する。'
	echo '          例: make modules SX_SYMBOLS=sx_uri_enc'
	echo '  test    全体版を生成してテストする。'
	echo '  clean   作成したファイルを削除する。'
	echo '  rebuild cleanの実行後にallを実行する。'
	echo '  help    このヘルプを表示して終了する。'
	echo '  version バージョン情報を表示して終了する。'

version:
	echo '$(VERSION)'
