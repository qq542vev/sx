FROM debian:13-slim

SHELL ["/bin/sh", "-euo", "pipefail", "-c"]

ARG USER_UID=1000
ARG USER_GID=1000

RUN \
	: == APTで必要なものをインストール == : && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y --no-install-recommends ca-certificates curl git m4 make && \
	: == 一般ユーザーと作業ディレクトリを作成 == : && \
	groupadd -g "${USER_GID}" agent && \
	useradd -m -u "${USER_UID}" -g agent -s /bin/bash agent && \
	mkdir -p /workspace && chown agent:agent /workspace && \
	: == ShellSpecを/usr/localにインストール == : && \
	curl -fsSL 'https://git.io/shellspec' | sh -s -- f2d13f991885ef44e6b54e571e0842222251b111 --yes --prefix /usr/local && \
	: == エージェントソフトウェアをインストール == : && \
	curl -fsSL 'https://opencode.ai/v2/install' | bash -s -- --no-modify-path && \
	curl -fsSL 'https://kilo.ai/cli/install' | bash -s -- --no-modify-path && \
	: == 実行ファイルを/usr/local/binに移動して、元の/root側を削除 == : && \
	mv -f ~/.opencode/bin/* ~/.kilo/bin/* /usr/local/bin && \
	rm -rf ~/.opencode ~/.kilo && \
	: == Yashのインストール == : && \
	ver=2.61 arc_name="yash-${ver}-linux-$(uname -m)" && \
	curl -fsSL "https://gitlab.com/qq542vev/build-yash/-/releases/${ver}/downloads/${arc_name}.tar.gz" | tar -xzC / --strip-components=1 "${arc_name}/usr/local/bin/yash" && \
	: == キャッシュなどを削除 == : && \
	apt-get purge -y ca-certificates curl && \
	apt-get autoremove -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ENV LANG='C.UTF-8'

USER agent
WORKDIR /workspace
