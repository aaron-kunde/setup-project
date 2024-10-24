#!/bin/sh
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
abort() {
    restore_exported_vars
    reset_global_vars

    return 0
}
local_installation_file_path() {
    echo /tmp/$(installation_file)
}
remote_installation_file_exists() {
    curl -sIf $(download_url) >/dev/null
}
download_installation_file() {
    echo "Download installation file"
    curl $(download_url) -o $(local_installation_file_path)
}
install() {
    echo "Install version: $VERSION"

    if [ ! -f $(local_installation_file_path) ]; then
	echo "Local installation file not found: $(local_installation_file_path). Try, download new one"
	if remote_installation_file_exists; then
	    download_installation_file
	else
	    echo "ERROR: No remote installation file found. Abort"
	    abort
	fi
    fi
    install_installation_file
 }
main() {
    init_global_vars
    set_vars_from_opts ${@}

    if ! is_installed; then
	echo "Start installation"
	restore_exported_vars
	export_vars
	install || abort
    fi

    reset_global_vars
    print_success_message
}

default_version() {
    echo v20.14.0
}
export_vars() {
    echo "Adding $(installation_path) to PATH"
    SETUP_NODEJS_ORIGINAL_PATH="${PATH}"

    export PATH="$(installation_path):${PATH}"
}
restore_exported_vars() {
    if [ -v SETUP_NODEJS_ORIGINAL_PATH ]; then
	export PATH="${SETUP_NODEJS_ORIGINAL_PATH}"
	unset SETUP_NODEJS_ORIGINAL_PATH
    fi
}
installation_path() {
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo $INSTALLATION_BASE_DIR/node-$VERSION-win-x64
	    ;;
	*)
	    echo $INSTALLATION_BASE_DIR/node-$VERSION-linux-x64/bin
	    ;;
    esac
}
is_installed() {
    node --version 2>/dev/null &&
	(node --version 2>&1 | grep $VERSION)
}
installation_file() {
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo node-$VERSION-win-x64.zip
	    ;;
	*)
	    echo node-$VERSION-linux-x64.tar.xz
	    ;;
    esac
}
install_installation_file() {
    local trgt_dir=$(dirname $(installation_path))

    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    unzip -oq $(local_installation_file_path) -d $trgt_dir
	    ;;
	*)
	    tar Jxf $(local_installation_file_path) -C $INSTALLATION_BASE_DIR
	    ;;
    esac
}
download_url() {
    echo https://nodejs.org/dist/$VERSION/$(installation_file)
}
print_success_message() {
    node -v
}

main ${@}
