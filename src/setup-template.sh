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
set_vars_from_opts() {
    while getopts v: opt; do
	case $opt in
	    v) VERSION=$OPTARG
	       ;;
	esac
    done
}
installation_path() {
    echo $INSTALLATION_BASE_DIR/tmpl-$VERSION
}
export_vars() {
    echo "Adding $(installation_path) to PATH"
    SETUP_TMPL_ORIGINAL_PATH="${PATH}"

    export PATH="$(installation_path):${PATH}"
}
restore_exported_vars() {
    if [ -v SETUP_TMPL_ORIGINAL_PATH ]; then
	export PATH="${SETUP_TMPL_ORIGINAL_PATH}"
	unset SETUP_TMPL_ORIGINAL_PATH
    fi
}

init_global_vars
set_vars_from_opts ${@}
restore_exported_vars
export_vars

echo "TODO: Not yet implemented"
print_usage

reset_global_vars
echo "TMPL successfully installed"
