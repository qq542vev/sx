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

.PHONY: all bundle test clean rebuild help version

.SILENT: help version

# Macro
# =====

VERSION = 0.0.1

TARGET = sx.sh
SOURCE = sx.m4
COMPACT = tools/compact.awk

# Build
# =====

all: $(TARGET)

# SX_SYMBOLS は make のコマンド行で指定する。コマンド行変数はレシピの環境へ継承される。
# 毎回生成し、異なる選択内容で同じ出力先を使っても古い内容を残さない。
bundle:
	@set -eu; \
	symbols=$${SX_SYMBOLS-}; \
	case "$$symbols" in '') echo 'SX_SYMBOLS を指定してください' >&2; exit 1;; esac; \
	out=$${SX_OUT:-sx-bundle.sh}; \
	case "$$out" in sx.sh) echo 'SX_OUT に sx.sh は指定できません' >&2; exit 1;; esac; \
	case "$$out" in */*) dir=$${out%/*}; case "$$dir" in '') dir=/;; esac; mkdir -p -- "$$dir";; esac; \
	raw="$$out.tmp"; compact="$$out.tmp2"; \
	trap 'rm -f -- "$$raw" "$$compact"' 0; \
	m4 "-DSX_SYMBOLS=$$symbols" -- m4/resolve.m4 > "$$raw"; \
	LC_ALL=C awk -f $(COMPACT) "$$raw" > "$$compact"; \
	chmod 755 -- "$$compact"; \
	mv -f -- "$$compact" "$$out"

$(TARGET): $(SOURCE) $(COMPACT) Makefile
	m4 -- $(SOURCE) >$@.tmp
	LC_ALL=C awk -f $(COMPACT) $@.tmp >$@.tmp2
	chmod 755 -- $@.tmp2
	mv -f -- $@.tmp2 $@
	rm -f -- $@.tmp

# Test
# ====

test: all
	shellspec

# Clean
# =====

clean:
	rm -f -- $(TARGET) $(TARGET).tmp $(TARGET).tmp2

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
	echo '  all     全てのファイルを作成する。'
	echo '  bundle  SX_SYMBOLS に指定した名前と依存先を SX_OUT（既定 sx-bundle.sh）へ出力する。'
	echo '          例: make SX_SYMBOLS=sx_uri_enc SX_OUT=sx-uri-enc.sh bundle'
	echo '  test    作成したファイルのテストを行う。'
	echo '  clean   作成したファイルを削除する。'
	echo '  rebuild cleanの実行後にallを実行する。'
	echo '  help    このヘルプを表示して終了する。'
	echo '  version バージョン情報を表示して終了する。'

version:
	echo '$(VERSION)'
