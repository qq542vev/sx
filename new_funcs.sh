sx_num_is_iwidth() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_iwidth "${@}" || return; return 0;; esac

	case "${1-}" in
		8 | 16 | 32 | 64 | 128) ;;
		*) return "${SX_EX_USAGE}";;
	esac

	__sx_num_is_iwidth "${@}"
}

### __sx_num_is_iwidth - すべての引数が指定されたビット幅の符号付き整数の範囲内か確認する（内部用）
__sx_num_is_iwidth() {
	__sx_num_is_iwidth_bits_="${1}"
	shift

	sx_num_is_int "${@}" || {
		unset __sx_num_is_iwidth_bits_
		return 1
	}

	# 基数8/16のパラメータ計算
	__sx_num_is_iwidth_xlen_=$(( __sx_num_is_iwidth_bits_ / 4 ))
	__sx_num_is_iwidth_olenn_=$(( (__sx_num_is_iwidth_bits_ - 1) / 3 + 1 ))
	__sx_num_is_iwidth_oleadn_=$(( 1 << ((__sx_num_is_iwidth_bits_ - 1) % 3) ))
	__sx_num_is_iwidth_olenp_=$(( __sx_num_is_iwidth_olenn_ - (__sx_num_is_iwidth_oleadn_ == 1) ))
	__sx_num_is_iwidth_oleadp_=$(( __sx_num_is_iwidth_oleadn_ == 1 ? 7 : __sx_num_is_iwidth_oleadn_ - 1 ))

	# 基数10のパラメータ設定
	case "${__sx_num_is_iwidth_bits_}" in
		8)   __sx_num_is_iwidth_dmax_=127 ;;
		16)  __sx_num_is_iwidth_dmax_=32767 ;;
		32)  __sx_num_is_iwidth_dmax_=2147483647 ;;
		64)  __sx_num_is_iwidth_dmax_=9223372036854775807 ;;
		128) __sx_num_is_iwidth_dmax_=170141183460469231731687303715884105727 ;;
	esac
	__sx_num_is_iwidth_dmin_="${__sx_num_is_iwidth_dmax_%7}8"
	__sx_num_is_iwidth_dlen_=${#__sx_num_is_iwidth_dmax_}

	for __sx_num_is_iwidth_arg_ in "${@}"; do
		case "${__sx_num_is_iwidth_arg_}" in
			-*) __sx_num_is_iwidth_sign_=-; __sx_num_is_iwidth_abs_=${__sx_num_is_iwidth_arg_#-} ;;
			*)  __sx_num_is_iwidth_sign_=;  __sx_num_is_iwidth_abs_=${__sx_num_is_iwidth_arg_#+} ;;
		esac

		case "${__sx_num_is_iwidth_abs_}" in
			0[xX]*)
				__sx_num_is_iwidth_abs_=${__sx_num_is_iwidth_abs_#??}
				__sx_num_is_iwidth_len_=${#__sx_num_is_iwidth_abs_}

				if __sx_num_lt "${__sx_num_is_iwidth_xlen_}" "${__sx_num_is_iwidth_len_}"; then
					unset __sx_num_is_iwidth_arg_ __sx_num_is_iwidth_bits_ __sx_num_is_iwidth_sign_ __sx_num_is_iwidth_abs_ __sx_num_is_iwidth_len_ __sx_num_is_iwidth_dmax_ __sx_num_is_iwidth_dmin_ __sx_num_is_iwidth_dlen_ __sx_num_is_iwidth_xlen_ __sx_num_is_iwidth_olenn_ __sx_num_is_iwidth_oleadn_ __sx_num_is_iwidth_olenp_ __sx_num_is_iwidth_oleadp_ __sx_num_is_iwidth_olen_ __sx_num_is_iwidth_olead_ __sx_num_is_iwidth_lim_ __sx_num_is_iwidth_pa_ __sx_num_is_iwidth_pb_ __sx_num_is_iwidth_ra_ __sx_num_is_iwidth_rb_
					return 1
				elif sx_str_eq "${__sx_num_is_iwidth_xlen_}" "${__sx_num_is_iwidth_len_}"; then
					case "${__sx_num_is_iwidth_sign_}${__sx_num_is_iwidth_abs_}" in -[9a-fA-F]* | -8*[!0]* | [89a-fA-F]*)
						unset __sx_num_is_iwidth_arg_ __sx_num_is_iwidth_bits_ __sx_num_is_iwidth_sign_ __sx_num_is_iwidth_abs_ __sx_num_is_iwidth_len_ __sx_num_is_iwidth_dmax_ __sx_num_is_iwidth_dmin_ __sx_num_is_iwidth_dlen_ __sx_num_is_iwidth_xlen_ __sx_num_is_iwidth_olenn_ __sx_num_is_iwidth_oleadn_ __sx_num_is_iwidth_olenp_ __sx_num_is_iwidth_oleadp_ __sx_num_is_iwidth_olen_ __sx_num_is_iwidth_olead_ __sx_num_is_iwidth_lim_ __sx_num_is_iwidth_pa_ __sx_num_is_iwidth_pb_ __sx_num_is_iwidth_ra_ __sx_num_is_iwidth_rb_
						return 1
					;; esac
				fi
				;;
			0?*)
				__sx_num_is_iwidth_abs_=${__sx_num_is_iwidth_abs_#0}
				__sx_num_is_iwidth_len_=${#__sx_num_is_iwidth_abs_}

				case "${__sx_num_is_iwidth_sign_}" in
					-) __sx_num_is_iwidth_olen_="${__sx_num_is_iwidth_olenn_}"; __sx_num_is_iwidth_olead_="${__sx_num_is_iwidth_oleadn_}" ;;
					*) __sx_num_is_iwidth_olen_="${__sx_num_is_iwidth_olenp_}"; __sx_num_is_iwidth_olead_="${__sx_num_is_iwidth_oleadp_}" ;;
				esac

				if __sx_num_lt "${__sx_num_is_iwidth_olen_}" "${__sx_num_is_iwidth_len_}"; then
					unset __sx_num_is_iwidth_arg_ __sx_num_is_iwidth_bits_ __sx_num_is_iwidth_sign_ __sx_num_is_iwidth_abs_ __sx_num_is_iwidth_len_ __sx_num_is_iwidth_dmax_ __sx_num_is_iwidth_dmin_ __sx_num_is_iwidth_dlen_ __sx_num_is_iwidth_xlen_ __sx_num_is_iwidth_olenn_ __sx_num_is_iwidth_oleadn_ __sx_num_is_iwidth_olenp_ __sx_num_is_iwidth_oleadp_ __sx_num_is_iwidth_olen_ __sx_num_is_iwidth_olead_ __sx_num_is_iwidth_lim_ __sx_num_is_iwidth_pa_ __sx_num_is_iwidth_pb_ __sx_num_is_iwidth_ra_ __sx_num_is_iwidth_rb_
					return 1
				elif sx_str_eq "${__sx_num_is_iwidth_olen_}" "${__sx_num_is_iwidth_len_}"; then
					case "${__sx_num_is_iwidth_sign_}" in
						-)
							case "${__sx_num_is_iwidth_abs_}" in [!0-${__sx_num_is_iwidth_oleadn_}]* | "${__sx_num_is_iwidth_oleadn_}"*[!0]*)
								unset __sx_num_is_iwidth_arg_ __sx_num_is_iwidth_bits_ __sx_num_is_iwidth_sign_ __sx_num_is_iwidth_abs_ __sx_num_is_iwidth_len_ __sx_num_is_iwidth_dmax_ __sx_num_is_iwidth_dmin_ __sx_num_is_iwidth_dlen_ __sx_num_is_iwidth_xlen_ __sx_num_is_iwidth_olenn_ __sx_num_is_iwidth_oleadn_ __sx_num_is_iwidth_olenp_ __sx_num_is_iwidth_oleadp_ __sx_num_is_iwidth_olen_ __sx_num_is_iwidth_olead_ __sx_num_is_iwidth_lim_ __sx_num_is_iwidth_pa_ __sx_num_is_iwidth_pb_ __sx_num_is_iwidth_ra_ __sx_num_is_iwidth_rb_
								return 1
							;; esac
							;;
						*)
							case "${__sx_num_is_iwidth_abs_}" in [!0-${__sx_num_is_iwidth_oleadp_}-]*)
								unset __sx_num_is_iwidth_arg_ __sx_num_is_iwidth_bits_ __sx_num_is_iwidth_sign_ __sx_num_is_iwidth_abs_ __sx_num_is_iwidth_len_ __sx_num_is_iwidth_dmax_ __sx_num_is_iwidth_dmin_ __sx_num_is_iwidth_dlen_ __sx_num_is_iwidth_xlen_ __sx_num_is_iwidth_olenn_ __sx_num_is_iwidth_oleadn_ __sx_num_is_iwidth_olenp_ __sx_num_is_iwidth_oleadp_ __sx_num_is_iwidth_olen_ __sx_num_is_iwidth_olead_ __sx_num_is_iwidth_lim_ __sx_num_is_iwidth_pa_ __sx_num_is_iwidth_pb_ __sx_num_is_iwidth_ra_ __sx_num_is_iwidth_rb_
								return 1
							;; esac
							;;
					esac
				fi
				;;
			*)
				__sx_num_is_iwidth_len_=${#__sx_num_is_iwidth_abs_}

				if __sx_num_lt "${__sx_num_is_iwidth_len_}" "${__sx_num_is_iwidth_dlen_}"; then
					: # OK
				elif __sx_num_lt "${__sx_num_is_iwidth_dlen_}" "${__sx_num_is_iwidth_len_}"; then
					unset __sx_num_is_iwidth_arg_ __sx_num_is_iwidth_bits_ __sx_num_is_iwidth_sign_ __sx_num_is_iwidth_abs_ __sx_num_is_iwidth_len_ __sx_num_is_iwidth_dmax_ __sx_num_is_iwidth_dmin_ __sx_num_is_iwidth_dlen_ __sx_num_is_iwidth_xlen_ __sx_num_is_iwidth_olenn_ __sx_num_is_iwidth_oleadn_ __sx_num_is_iwidth_olenp_ __sx_num_is_iwidth_oleadp_ __sx_num_is_iwidth_olen_ __sx_num_is_iwidth_olead_ __sx_num_is_iwidth_lim_ __sx_num_is_iwidth_pa_ __sx_num_is_iwidth_pb_ __sx_num_is_iwidth_ra_ __sx_num_is_iwidth_rb_
					return 1
				else
					case "${__sx_num_is_iwidth_sign_}" in
						-) __sx_num_is_iwidth_lim_="${__sx_num_is_iwidth_dmin_}" ;;
						*) __sx_num_is_iwidth_lim_="${__sx_num_is_iwidth_dmax_}" ;;
					esac

					while case "${__sx_num_is_iwidth_abs_}" in ?*) ;; *) ! : ;; esac; do
						case "${__sx_num_is_iwidth_abs_}" in
							????????*)
								__sx_num_is_iwidth_ra_="${__sx_num_is_iwidth_abs_#????????}"
								__sx_num_is_iwidth_pa_="${__sx_num_is_iwidth_abs_%${__sx_num_is_iwidth_ra_}}"
								__sx_num_is_iwidth_rb_="${__sx_num_is_iwidth_lim_#????????}"
								__sx_num_is_iwidth_pb_="${__sx_num_is_iwidth_lim_%${__sx_num_is_iwidth_rb_}}"
								__sx_num_is_iwidth_abs_="${__sx_num_is_iwidth_ra_}"
								__sx_num_is_iwidth_lim_="${__sx_num_is_iwidth_rb_}"
								;;
							*)
								__sx_num_is_iwidth_pa_="${__sx_num_is_iwidth_abs_}"
								__sx_num_is_iwidth_pb_="${__sx_num_is_iwidth_lim_}"
								__sx_num_is_iwidth_abs_=
								;;
						esac

						if __sx_num_lt "$((1${__sx_num_is_iwidth_pa_}))" "$((1${__sx_num_is_iwidth_pb_}))"; then
							break
						elif __sx_num_lt "$((1${__sx_num_is_iwidth_pb_}))" "$((1${__sx_num_is_iwidth_pa_}))"; then
							unset __sx_num_is_iwidth_arg_ __sx_num_is_iwidth_bits_ __sx_num_is_iwidth_sign_ __sx_num_is_iwidth_abs_ __sx_num_is_iwidth_len_ __sx_num_is_iwidth_dmax_ __sx_num_is_iwidth_dmin_ __sx_num_is_iwidth_dlen_ __sx_num_is_iwidth_xlen_ __sx_num_is_iwidth_olenn_ __sx_num_is_iwidth_oleadn_ __sx_num_is_iwidth_olenp_ __sx_num_is_iwidth_oleadp_ __sx_num_is_iwidth_olen_ __sx_num_is_iwidth_olead_ __sx_num_is_iwidth_lim_ __sx_num_is_iwidth_pa_ __sx_num_is_iwidth_pb_ __sx_num_is_iwidth_ra_ __sx_num_is_iwidth_rb_
							return 1
						fi
					done
				fi
				;;
		esac
	done

	unset __sx_num_is_iwidth_arg_ __sx_num_is_iwidth_bits_ __sx_num_is_iwidth_sign_ __sx_num_is_iwidth_abs_ __sx_num_is_iwidth_len_ __sx_num_is_iwidth_dmax_ __sx_num_is_iwidth_dmin_ __sx_num_is_iwidth_dlen_ __sx_num_is_iwidth_xlen_ __sx_num_is_iwidth_olenn_ __sx_num_is_iwidth_oleadn_ __sx_num_is_iwidth_olenp_ __sx_num_is_iwidth_oleadp_ __sx_num_is_iwidth_olen_ __sx_num_is_iwidth_olead_ __sx_num_is_iwidth_lim_ __sx_num_is_iwidth_pa_ __sx_num_is_iwidth_pb_ __sx_num_is_iwidth_ra_ __sx_num_is_iwidth_rb_
}
