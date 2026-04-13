var_set() {
	var_move __var_set_OPTARG=OPTARG __var_set_OPTIND=OPTIND

	while getopts p:s: __var_set_opt; do
		case "${opt}" in
			p) __var_set_prefix="${OPTARG}";;
			s) __var_set_suffix="${OPTARG}";;
			*)
				var_move OPTARG=__var_set_OPTARG OPTIND=__var_set_OPTIND
				unset __var_set_opt __var_set_prefix __var_set_suffix
				return 64
				;;
		esac
	done

	shift "$$(OPTIND - 1)"

	for __var_set_arg in "${@}"; do
		if ! var_is_writable "${__var_set_prefix-}${__var_set_arg%%=*}${__var_set_suffix-}"; then
			eval 'unset __var_set_opt __var_set_prefix __var_set_suffix;' return "${?}"
		fi
	done

	for __var_set_arg in "${@}"; do
		case "${__var_set_arg}" in
			*=*) eval "${__var_set_prefix-}${__var_set_arg%%=*}${__var_set_suffix-}="'${__var_set_arg#*=}';;
			*) eval "${__var_set_prefix-}${__var_set_arg}${__var_set_suffix-}=";;
		esac
	done

	var_move OPTARG=__var_set_OPTARG OPTIND=__var_set_OPTIND
	unset __var_set_arg
}

var_list_set() {
	set | while IFS='=' read -r name val; do
		var_is_set "${name}" || continue

		case "${list-}" in
			*" ${name} "*) continue;;
		esac

		printf '%s\n' "${name}"
		list="${list:- }${name} "
	done
}

var_list_readonly() {
	readonly -p | while IFS=' =' read -r type name val; do
		case "${type}" in
			readonly) var_is_readonly "${name}" || continue;;
			*) continue;;
		esac

		case "${list-}" in
			*" ${name} "*) continue;;
		esac

		printf '%s\n' "${name}"
		list="${list:- }${name} "
	done
}

var_copy() {
	for __var_copy_arg in "${@}"; do
		if [ "${__var_copy_arg#*=}" = "${__var_copy_arg}" ] || ! var_arg_check "${__var_copy_arg#*=}"; then
			printf 'var_copy: %s is invalid.' "${__var_copy_arg}" >&2
			eval 'unset __var_copy_arg;' return 64
		elif ! var_is_writable "${__var_copy_arg%%=*}"; then
			case "${?}" in
				64)
					printf 'var_copy: %s is invalid.' "${__var_copy_arg}" >&2
					eval 'unset __var_copy_arg;' return 64
					;;
				*)
					printf 'var_copy: %s is readonly.' "${__var_copy_arg%%=*}" >&2
					eval 'unset __var_copy_arg;' return 1
					;;
			esac
		fi
	done

	for __var_copy_arg in "${@}"; do
		if var_is_set "${__var_copy_arg#*=}"; then
			eval "${__var_copy_arg%%=*}=\${${__var_copy_arg#*=}}"
		else
			unset "${__var_copy_arg%%=*}"
		fi
	done

	unset __var_copy_arg
}

var_move() {
	for __var_move_arg in "${@}"; do
		if ! var_is_writable "${__var_move_arg#*=}"; then
			case "${?}" in
				64)
					printf 'var_move: %s is invalid.' "${__var_move_arg}" >&2
					eval 'unset __var_move_arg;' return 64
					;;
				*)
					printf 'var_move: %s is readonly.' "${__var_move_arg%%=*}" >&2
					eval 'unset __var_move_arg;' return 1
					;;
			esac
		fi
	done

	var_copy "${@}"

	for __var_move_arg in "${@}"; do
		unset "${__var_move_arg#*=}"
	done

	unset __var_move_arg
}

var_swap() {
	for __var_swap_arg in "${@}"; do
		if ! var_is_writable "${__var_move_arg#*=}"; then
			case "${?}" in
				64)
					printf 'var_move: %s is invalid.' "${__var_move_arg}" >&2
					eval 'unset __var_move_arg;' return 64
					;;
				*)
					printf 'var_move: %s is readonly.' "${__var_move_arg%%=*}" >&2
					eval 'unset __var_move_arg;' return 1
					;;
			esac
		fi


		if var_move "__var_swap_tmp=${__var_copy_arg%%=*}" && var_move "${__var_copy_arg}" && var_move "${__var_copy_arg#*=}=__var_swap_tmp"; then
			case "${?}" in
				64)
					printf 'var_swap: %s is invalid.' "${__var_swap_arg}" >&2
					eval 'unset __var_swap_arg;' return 64
					;;
				*)
					printf 'var_swap: %s is readonly.' "${__var_swap_arg%%=*}" >&2
					eval 'unset __var_swap_arg;' return 1
					;;
			esac

		fi
	done
}

var_is_set() {
	var_name_check "${1}" || return 64

	eval case "\"\${${1}+X}\"" in '"") return 1;;' esac
}

var_is_unset() {
	var_name_check "${1}" || return 2

	eval case "\"\${${1}+X}\"" in '"X") return 1;;' esac
}

var_has_value() {
	var_is_set "${1}" || return "${?}"

	eval case "\"\${${1}}\"" in '"") return 1;;' esac
}

var_is_empty() {
	var_is_set "${1}" || return "${?}"

	eval case "\"\${${1}}\"" in '"?") return 1;;' esac
}

var_is_writable() {
	var_name_check "${1}" || return 64

	(eval "${1}=") 2>/dev/null || return 1
}

var_is_readonly() {
	var_name_check "${1}" || return 64

	(eval "${1}=") 2>/dev/null || return 0

	return 1
}

var_name_check() {
	case "${1}" in
		'' | [0-9]* | *[!_A-Za-z]*) return 1;;
	esac
}
