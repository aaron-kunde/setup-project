#!/bin/sh
__sp_init_global_vars() {
    __sp_version=$(default_version)
    __sp_installation_base_dir=$HOME/opt
    # Reset OPTIND, if getopts was used before
    OPTIND=1
}
reset_global_vars() {
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
abort() {
    __sp_restore_exported_vars
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
    echo "Install version: $__sp_version"

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
__sp_main() {
    __sp_init_global_vars
    __sp_set_vars_from_opts ${@}

    if ! __sp_is_installed; then
	echo "Start installation"
	__sp_restore_exported_vars
	__sp_export_vars
	install || abort
    fi

    reset_global_vars
    print_success_message
}

default_version() {
    echo tmpl_default-version
}
__sp_export_vars() {
    echo "Add $(installation_path) to PATH"
    __SP_TMPL_ORIGINAL_PATH="${PATH}"

    export PATH="$(installation_path):${PATH}"
}
__sp_restore_exported_vars() {
    if [ -v __SP_TMPL_ORIGINAL_PATH ]; then
	export PATH="${__SP_TMPL_ORIGINAL_PATH}"
	unset __SP_TMPL_ORIGINAL_PATH
    fi
}
installation_path() {
    echo $__sp_installation_base_dir/tmpl-$__sp_version
}
__sp_is_installed() {
    case "$__sp_version" in
	installed) return 0
	    ;;
	*) return 1
	    ;;
    esac
}
installation_file() {
    echo installation.file
}
install_installation_file() {
    echo "Install installation file"
	case "$__sp_version" in
	installation_fail) return 1
	   ;;
	*) return 0
	   ;;
    esac
}
download_url() {
    case "$__sp_version" in
	download_fail) echo https://github.com/aaron-kunde/setup-project/blob/main/non-existing.file
	   ;;
	*) echo https://github.com/aaron-kunde/setup-project/blob/main/README.org
	   ;;
    esac
}
print_success_message() {
    echo "TMPL successfully installed"
}

__sp_main ${@}
