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
##   depends - awk, chmod, cmp, echo, find, m4, mkdir, mv, printf, python3, rm, shellspec, sort
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/sx>
##   * <Bag report at https://github.com/qq542vev/sx/issues>

# Sp Targets
# ==========

.POSIX:

.PHONY: all bundle module FORCE test clean rebuild help version

.SILENT: help version

# Macro
# =====

VERSION = 0.0.1

COMPACT = tools/compact.awk
TEST_FLAGS =

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

# 単位ファイルを列挙する。直接 module.mk を使う場合は、この一覧を更新しない。
module.mk: FORCE
	@set -efu; \
	tmp=module.mk.tmp.$$$$; files=$$tmp.files; \
	trap 'rm -f -- "$$tmp" "$$files"' 0; \
	find src/const src/var src/func -type f -name '*.m4' -print > "$$files"; \
	LC_ALL=C sort -o "$$files" "$$files"; \
	{ \
		printf '%s\n' '# Makefile から自動生成。編集せず make module.mk で更新する。' '.POSIX:' '' '.PHONY: all' ''; \
		printf 'MODULE_SOURCES = src/const.m4 src/var.m4 src/func.m4'; \
		while IFS= read -r path; do printf ' %s' "$$path"; done < "$$files"; \
		printf '\nMODULE_BUILD_FILES = Makefile m4/common.m4 m4/resolve.m4 %s\n\nall:' '$(COMPACT)'; \
		seen=; \
		while IFS= read -r path; do \
			name=$${path##*/}; symbol=$${name%.m4}; \
			case "$$symbol" in '' | [0-9]* | *[!A-Za-z0-9_]*) echo "提供名の形式が不正です: $$path" >&2; exit 1;; esac; \
			case " $$seen " in *" $$symbol "*) echo "提供名が重複しています: $$symbol" >&2; exit 1;; esac; \
			seen="$$seen $$symbol"; \
			printf ' build/modules/%s.sh' "$$symbol"; \
		done < "$$files"; \
		printf '\n\n'; \
		while IFS= read -r path; do \
			name=$${path##*/}; symbol=$${name%.m4}; \
			printf 'build/modules/%s.sh: $$(MODULE_SOURCES) $$(MODULE_BUILD_FILES)\n' "$$symbol"; \
			printf '\t$$(MAKE) -f Makefile bundle SX_SYMBOLS=%s SX_OUT="$$@"\n\n' "$$symbol"; \
		done < "$$files"; \
	} > "$$tmp"; \
	if [ -f module.mk ] && cmp -s "$$tmp" module.mk; then :; else mv -f -- "$$tmp" module.mk; fi

# 全単位を依存先込みで生成する。並列数は make -j で指定できる。
module: module.mk
	$(MAKE) -f module.mk

FORCE:

# Test
# ====

test:
	$(MAKE) SX_SYMBOLS= SX_OUT=sx.sh all
	$(MAKE) module
	unset SXTEST_LOAD_MOD; shellspec $(TEST_FLAGS)
	SXTEST_LOAD_MOD=sx.sh shellspec $(TEST_FLAGS)

# Clean
# =====

clean:
	rm -f -- sx.sh sx.sh.tmp sx.sh.tmp2
	rm -f -- module.mk module.mk.tmp.*
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
	echo '  module  src の全単位を build/modules/<名前>.sh に個別生成する。'
	echo '  module.mk 個別生成のルールを更新する。ファイル追加・削除時にも実行する。'
	echo '          例: make -f module.mk build/modules/sx_uri_enc.sh'
	echo '          make -f module.mk は生成済みの一覧で全単位を生成する。'
	echo '  test    全体版を生成してテストする。'
	echo '  clean   作成したファイルを削除する。'
	echo '  rebuild cleanの実行後にallを実行する。'
	echo '  help    このヘルプを表示して終了する。'
	echo '  version バージョン情報を表示して終了する。'

version:
	echo '$(VERSION)'
