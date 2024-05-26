#!/bin/sh
default_version() {
    echo tmpl_default-version
}
print_usage() {
    cat <<EOM
${0} [-v VERSION]
     -v VERSION Version of TMPL to install.
	Default: $(default_version)
EOM
}
init_global_vars() {
    VERSION=$(default_version)
    INSTALLATION_BASE_DIR=$HOME/opt
    # Reset OPTIND, if getopts was used before
    OPTIND=1
}
reset_global_vars() {
    unset VERSION
    unset INSTALLATION_BASE_DIR
    # Reset OPTIND for future use of getopts
    OPTIND=1
}

init_global_vars

echo "TODO: Not yet implemented"
print_usage

reset_global_vars
