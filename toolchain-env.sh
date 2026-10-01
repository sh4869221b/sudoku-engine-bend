# Source after changing to the project root. No ambient BEND/CC/BENDTT is used.
# BEND_TOOLCHAIN_DIR can select an installation made from this exact lockfile.
_bend_environment=$(python3 qa/toolchain.py env) || return 1
eval "$_bend_environment"
unset _bend_environment
