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
##   depends - chmod, echo, m4, rm, shellspec
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/sx>
##   * <Bag report at https://github.com/qq542vev/sx/issues>

# Sp Targets
# ==========

.POSIX:

.PHONY: all test clean rebuild help version

.SILENT: help version

# Macro
# =====

VERSION = 0.0.1

TARGET = sx.sh
SOURCE = sx.m4

# Build
# =====

all: $(TARGET)

$(TARGET): $(SOURCE)
	m4 -- $(SOURCE) > $(TARGET)
	chmod 755 -- $(TARGET)

# Test
# ====

test: all
	shellspec

# Clean
# =====

clean:
	rm -f -- $(TARGET)

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
	echo '  test    作成したファイルのテストを行う。'
	echo '  clean   作成したファイルを削除する。'
	echo '  rebuild cleanの実行後にallを実行する。'
	echo '  help    このヘルプを表示して終了する。'
	echo '  version バージョン情報を表示して終了する。'

version:
	echo '$(VERSION)'
