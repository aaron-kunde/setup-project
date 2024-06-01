#!/bin/sh
default_version() {
    echo tmpl_default-version
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
abort() {
    restore_exported_vars
    reset_global_vars

    return 0
}
installation_file() {
    echo installation.file
}
local_installation_file_path() {
    echo /tmp/$(installation_file)
}
is_installed() {
    case "$VERSION" in
	installed) return 0
	    ;;
	*) return 1
	    ;;
    esac
}
download_url() {
    case "$VERSION" in
	download_fail) echo https://github.com/aaron-kunde/setup-project/blob/main/non-existing.file
	   ;;
	*) echo https://github.com/aaron-kunde/setup-project/blob/main/README.org
	   ;;
    esac
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
install_installation_file() {
    echo "Install installation file"
	case "$VERSION" in
	installation_fail) return 1
	   ;;
	*) return 0
	   ;;
    esac
}
print_success_message() {
    echo "TMPL successfully installed"
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

main ${@}
