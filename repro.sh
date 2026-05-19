sx_cfg_is_valid() {
    for __sx_cfg_is_valid_arg in "${@}"; do
        __sx_cfg_is_valid_vn="${__sx_cfg_is_valid_arg%%=*}"
        __sx_cfg_is_valid_val="${__sx_cfg_is_valid_arg#*=}"
        case "${__sx_cfg_is_valid_vn}" in
            NUM_RANGE) case "${__sx_cfg_is_valid_val}" in 8|16|32|64|128);; *) ! :;; esac;;
            *) ! :;;
        esac || {
            unset __sx_cfg_is_valid_arg __sx_cfg_is_valid_vn __sx_cfg_is_valid_val
            return 1
        }
    done
    unset __sx_cfg_is_valid_arg __sx_cfg_is_valid_vn __sx_cfg_is_valid_val
}

sx_cfg_is_valid NUM_RANGE=99
echo $?

set | grep __sx_cfg_is_valid

