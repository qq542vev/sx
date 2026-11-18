dnl glob の特殊文字マクロ (M_GLOB_SP_*)
define([|M_GLOB_SP_NORM|], [|[|*?[\|]|])dnl
define([|M_GLOB_SP_NORM_ARGS|], [|[|'*' '?' '[' '\'|]|])dnl
define([|M_GLOB_SP_NORM_ESC_ARGS|], [|[|'[*]' '[?]' '[[]' '[\\]'|]|])dnl
define([|M_GLOB_SP_BRKT|], [|[|!-.:=[\]^|]|])dnl
define([|M_GLOB_SP_BRKT_ARGS|], [|[|'!' '-' '.' ':' '=' '[' '\' ']' '^'|]|])dnl
