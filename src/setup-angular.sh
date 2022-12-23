init_global_vars() {
    DEFAULT_VERSION=v15.0
    VERSION=$DEFAULT_VERSION
    OPTIND=1
}

print_usage() {
    cat <<EOM
${0} [-v VERSION]
     -v VERSION Version of Angular to install.
     	Default: $DEFAULT_VERSION
EOM
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
    echo "./node_modules/.bin"
}

export_path_vars() {
    echo "Adding $(installation_path) to PATH"
    SETUP_ANGULAR_ORIGINAL_PATH="${PATH}"
    
    export PATH="$(installation_path):${PATH}"
}

reset_path_vars() {
    if [ -v SETUP_ANGULAR_ORIGINAL_PATH ]; then
	export PATH="${SETUP_ANGULAR_ORIGINAL_PATH}"
	unset SETUP_ANGULAR_ORIGINAL_PATH
    fi
}

reset_global_vars() {
    unset DEFAULT_NODEJS_VERSION
    unset DEFAULT_VERSION
    unset VERSION
    OPTIND=1
}

abort() {
    reset_path_vars
    reset_global_vars

    return 0
}

is_installed() {
    ng version 2>/dev/null &&
	(ng version 2>&1 | grep $VERSION)

}

install_installation_file() {
    echo "Install installation file"
    npm install @angular/cli@$VERSION
}

install() {
    echo "Install new version: $VERSION"

    install_installation_file
}

init_global_vars
reset_path_vars
set_vars_from_opts ${@}
export_path_vars

if ! is_installed; then
    install || abort
fi

ng version

reset_global_vars
