#!/bin/sh

# sx_num_int_add_abs ベンチマーク
set -eu

ITER=${1:-20000}
ITER_LARGE=${2:-500}

. ./sx.sh

NL='
'

__parse_times() {
	__line1_=${1%%${NL}*}
	__user_=${__line1_%% *}
	__tmp_=${__user_#*m}; __tmp_=${__tmp_%s}
	__s_=${__tmp_%.*}; __f_=${__tmp_#*.}
	__d_=${__f_%"${__f_#?}"}
	__t_=$(( (${__user_%%m*} * 60 + ${__s_}) * 10 + ${__d_} ))
	echo "${__t_}"
}

__bench() {
	__label_="$1"
	__code_="$2"
	__n_="$3"

	__raw_=$(i=0
		while :; do
			: $((i += 1))
			eval "${__code_}"
			case ${i} in "${__n_}") break;; esac
		done
		times 2>&1)

	__t_=$(__parse_times "${__raw_}")
	case ${__t_} in ""|*[!0-9]*) __t_=1;; esac
	case ${__t_} in 0) __t_=1;; esac

	printf "  %-50s %5d iter/tenth  %7d iter/sec  (tenth=%d)\n" \
		"${__label_}" \
		"$((__n_ / __t_))" \
		"$((__n_ * 10 / __t_))" \
		"${__t_}"
}

printf "=== sx_num_int_add_abs 最適化検証 ===\n"
printf "Shell: yash -o posix\n"
printf "ITER:  %d  (超大のみ %d)\n\n" "${ITER}" "${ITER_LARGE}"

printf "%s\n" "--- A-G: 従来シナリオ（再掲） ---"
__bench "A   123 + 456 (3dg)" \
	"sx_num_int_add_abs __out 123 456" "${ITER}"
__bench "B   999999999 + 1 (9dg)" \
	"sx_num_int_add_abs __out 999999999 1" "${ITER}"
__bench "C   999999999999999999 + 1 (18dg)" \
	"sx_num_int_add_abs __out 999999999999999999 1" "${ITER}"
__bench "D   12345678901234567890 + 987... (20dg)" \
	"sx_num_int_add_abs __out 12345678901234567890 98765432109876543210" "${ITER}"
__bench "E   999999999 x5" \
	"sx_num_int_add_abs __out 999999999 999999999 999999999 999999999 999999999" "${ITER}"
__bench "F   0 x5" \
	"sx_num_int_add_abs __out 0 0 0 0 0" "${ITER}"
__bench "G   999...9(30dg) + 1" \
	"sx_num_int_add_abs __out 999999999999999999999999999999 1" "${ITER}"

printf "\n%s\n" "--- H-L: 0*ガード発動シナリオ ---"
__bench "H   1000...0(19dg) + 1" \
	"sx_num_int_add_abs __out 1000000000000000000 1" "${ITER}"
__bench "I   1000...0(19dg) + 0" \
	"sx_num_int_add_abs __out 1000000000000000000 0" "${ITER}"
__bench "J   123000000000 + 456 (12dg,下位0)" \
	"sx_num_int_add_abs __out 123000000000 456" "${ITER}"
__bench "K   100...0(27dg) + same" \
	"sx_num_int_add_abs __out 100000000000000000000000000 100000000000000000000000000" "${ITER}"

printf "\n%s\n" "--- 複数回連続（ばらつき確認, ITER=10000） ---"
ITER_SMALL=10000
i=0
while :; do
	: $((i += 1))
	case ${i} in 4) break;; esac
	printf "  Run %d/3:\n" "${i}"
	__bench "    999999999 + 1" \
		"sx_num_int_add_abs __out 999999999 1" "${ITER_SMALL}"
	__bench "    1000...0(19dg) + 1" \
		"sx_num_int_add_abs __out 1000000000000000000 1" "${ITER_SMALL}"
	__bench "    12345678901234567890 + 987..." \
		"sx_num_int_add_abs __out 12345678901234567890 98765432109876543210" "${ITER_SMALL}"
done
