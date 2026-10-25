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

.SILENT: bundle help version

# Macro
# =====

VERSION = 0.0.1

COMPACT = tools/compact.awk
TEST_FLAGS =
MOD_DIR = build/modules
MOD_EXT = .sh

# Build
# =====

all: bundle

# SYMBOLS と OUT は make のコマンド行で指定できる。
# OUT が未指定または空文字列なら標準出力へ出力する。
# 選択内容と出力先が変わっても反映されるよう、毎回生成する。
bundle:
	set -efu -o pipefail; \
	case "$${OUT:+X}" in X) \
		tmp=$$(echo 'mkstemp(./tmpXXXXXX)' | m4); \
		trap 'rm -f -- "$${tmp}"' 0; \
		chmod -- u+w "$${tmp}"; \
		exec >"$${tmp}"; \
		case "$${OUT}" in *?/*) \
			mkdir -p -- "$${OUT%/*}"; \
		esac; \
	esac; \
	m4 "-DSX_SYMBOLS=$${SYMBOLS-}" -- m4/resolve.m4 | LC_ALL=C awk -f $(COMPACT); \
	case "$${OUT:+X}" in X) \
		chmod -- =rw "$${tmp}"; \
		mv -- "$${tmp}" "$${OUT}"; \
	esac

# 単位ファイルを列挙する。直接 module.mk を使う場合は、この一覧を更新しない。
module.mk: FORCE
	set -efu -o pipefail; \
	symbols=$$(find src/const src/var src/func -type f -name '*?.m4' ! -name '*[!_0-9A-Za-z]*.m4' | xargs -I ARG basename ARG .m4 | tr '\n' ' '); symbols="$${symbols% }"; \
	tmp=$$(echo 'mkstemp(./tmpXXXXXX)' | m4); \
	trap 'rm -f -- "$${tmp}"' 0; \
	chmod -- u+w "$${tmp}"; \
	printf '%s\n' >"$${tmp}" \
	'#!/usr/bin/make -f' \
	'' \
	'.POSIX:' \
	'' \
	'.PHONY: FORCE all list clean' \
	'' \
	'MOD_DIR = $(MOD_DIR)' \
	'MOD_EXT = $(MOD_EXT)' \
	"MOD_SYMBOLS = $${symbols}" \
	'MOD_TARGETS = $$(MOD_SYMBOLS:%=$$(MOD_DIR)/%$$(MOD_EXT))' \
	'' \
	'all: $$(MOD_TARGETS)' \
	'' \
	'list:' \
	'	printf "%s\\n" $$(MOD_TARGETS)' \
	'' \
	'clean:' \
	'	rm -f -- $$(MOD_TARGETS)' \
	'FORCE:' \
	'' \
	'$$(MOD_TARGETS): FORCE' \
	'	$$(MAKE) SYMBOLS="$$(@F:$$(MOD_EXT)=)" OUT="$$(@)" bundle'; \
	chmod -- =rwx "$${tmp}"; \
	mv -- "$${tmp}" "$(@)"

# 全単位を依存先込みで生成する。並列数は make -j で指定できる。
module: module.mk
	$(MAKE) -f module.mk

FORCE:

# Test
# ====

test: module
	$(MAKE) SYMBOLS= OUT=sx.sh all
	unset SXTEST_LOAD_MOD; shellspec $(TEST_FLAGS)

# Clean
# =====

clean:
	rm -f -- sx.sh module.mk '$(MOD_DIR)'/*'$(MOD_EXT)'

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
	echo '  all     全体版、または SYMBOLS で選択した部分版を生成する（既定）。'
	echo '  bundle  all と同じ生成処理を実行する。'
	echo '  module  src の全単位を MOD_DIR/<名前>MOD_EXT に個別生成する。'
	echo '  module.mk 個別生成のルールを更新する。ファイル追加・削除時にも実行する。'
	echo '          例: make -f module.mk build/modules/sx_uri_enc.sh'
	echo '          make -f module.mk は生成済みの一覧で全単位を生成する。'
	echo '  test    個別モジュールと sx.sh を生成し、個別モジュールでテストする。'
	echo '  clean   sx.sh、module.mk、MOD_DIR 内の MOD_EXT を持つファイルを削除する。'
	echo '  rebuild clean の実行後に all を実行する。'
	echo '  help    このヘルプを表示して終了する。'
	echo '  version バージョン情報を表示して終了する。'
	echo
	echo 'MACRO:'
	echo '  SYMBOLS 生成する単位名。複数指定は空白で区切る。未指定・空文字列なら全単位。'
	echo '  OUT     出力先。未指定・空文字列なら標準出力（all、bundle）。'
	echo '  MOD_DIR 個別モジュールの出力ディレクトリ（既定 build/modules）。'
	echo '  MOD_EXT 個別モジュールの拡張子（既定 .sh）。'
	echo '  TEST_FLAGS shellspec に渡すオプション。'
	echo
	echo 'EXAMPLE:'
	echo '  make OUT=sx.sh'
	echo '  make SYMBOLS=sx_uri_enc OUT=sx-uri-enc.sh'
	echo '  make SYMBOLS="sx_uri_enc sx_uri_is_pct"'
	echo '  make MOD_DIR=build/custom MOD_EXT=.sh module'

version:
	echo '$(VERSION)'
