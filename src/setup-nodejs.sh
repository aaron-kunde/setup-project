#!/bin/sh
__sp_init_global_vars() {
    __sp_version=$(__sp_default_version)
    __sp_installation_base_dir=$HOME/opt
    # Reset OPTIND, if getopts was used before
    OPTIND=1
}
__sp_reset_custom_vars_and_funcs() {
    unset $(declare | grep '^__sp_' | tr '=' ' ' | cut -f1 -d ' ')
    # Reset OPTIND for future use of getopts
    OPTIND=1
}
__sp_set_vars_from_opts() {
    while getopts v: opt; do
	case $opt in
	    v) __sp_version=$OPTARG
	       ;;
	esac
    done
}
__sp_abort() {
    __sp_restore_exported_vars

    return 0
}
__sp_local_installation_file_path() {
    echo /tmp/$(__sp_installation_file)
}
__sp_remote_installation_file_exists() {
    curl -sIf $(__sp_download_url) >/dev/null
}
__sp_download_installation_file() {
    echo "Download installation file"
    curl $(__sp_download_url) -o $(__sp_local_installation_file_path)
}
__sp_install() {
    echo "Install version: $__sp_version"

    if [ ! -f $(__sp_local_installation_file_path) ]; then
	echo "Local installation file not found: $(__sp_local_installation_file_path). Try, download new one"
	if __sp_remote_installation_file_exists; then
	    __sp_download_installation_file
	else
	    echo "ERROR: No remote installation file found. Abort"
	    __sp_abort
	fi
    fi
    __sp_install_installation_file
 }
__sp_main() {
    __sp_init_global_vars
    __sp_set_vars_from_opts ${@}

    if ! __sp_is_installed; then
	echo "Start installation"
	__sp_restore_exported_vars
	__sp_export_vars
	__sp_install || __sp_abort
    fi

    __sp_print_success_message
    __sp_reset_custom_vars_and_funcs
}

__sp_default_version() {
    echo v20.14.0
}
export_vars() {
    echo "Add $(__sp_installation_path) to PATH"
    __SP_NODEJS_ORIGINAL_PATH="${PATH}"

    export PATH="$(__sp_installation_path):${PATH}"
}
restore_exported_vars() {
    if [ -v __SP_NODEJS_ORIGINAL_PATH ]; then
	export PATH="${__SP_NODEJS_ORIGINAL_PATH}"
	unset __SP_NODEJS_ORIGINAL_PATH
    fi
}
__sp_installation_path() {
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
    local trgt_dir=$(dirname $(__sp_installation_path))

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

__sp_main ${@}
