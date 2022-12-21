# Specific implementation needed
init_global_vars() {
    DEFAULT_TMPL_VERSION=default_version
    TMPL_VERSION=$DEFAULT_TMPL_VERSION
    INSTALLATION_BASE_DIR=$HOME/opt
    # Reset OPTIND, if getopts was used before
    OPTIND=1
}

# Specific implementation needed
print_usage() {
    cat <<EOM
${0} [-v VERSION]
     -v VERSION Version of TMPL to install.
     	Default: $DEFAULT_TMPL_VERSION
EOM
}

# Specific implementation needed
set_vars_from_opts() {
    while getopts v: opt; do
	case $opt in
	    v) TMPL_VERSION=$OPTARG
	       ;;
	esac
    done
}

# Specific implementation needed
installation_path() {
    # There might be different installation paths, depending on target OS
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo $INSTALLATION_BASE_DIR/tmpl-$TMPL_VERSION
	    ;;
	*)
	    echo $INSTALLATION_BASE_DIR/tmpl-$TMPL_VERSION
	    ;;
    esac
}

# Specific implementation needed
export_path_vars() {
    echo "Adding $(installation_path) to PATH"
    SETUP_TMPL_ORIGINAL_PATH="${PATH}"
    
    export PATH="$(installation_path):${PATH}"
}

# Specific implementation needed
reset_path_vars() {
    if [ -v SETUP_TMPL_ORIGINAL_PATH ]; then
	export PATH="${SETUP_TMPL_ORIGINAL_PATH}"
	unset SETUP_TMPL_ORIGINAL_PATH
    fi
}

# Specific implementation needed
reset_global_vars() {
    unset TMPL_VERSION
    unset DEFAULT_TMPL_VERSION
    unset INSTALLATION_BASE_DIR
    # Reset OPTIND for future use of getopts
    OPTIND=1
}

abort() {
    reset_path_vars
    reset_global_vars

    return 0
}

# Specific implementation needed
is_installed() {
    case "$TMPL_VERSION" in
	installed) return 0
	    ;;
	*) return 1
	    ;;
    esac
}

# Specific implementation needed
installation_file() {
    # There might be different installation files, depending on target OS
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo installation.file
	    ;;
	*)
	    echo installation.file
	    ;;
    esac
}

local_installation_file() {
    echo /tmp/$(installation_file)
}

local_installation_file_exists() {
    test -f $(local_installation_file)
}

# Specifc implermentation needed
download_url() {
    case "$TMPL_VERSION" in
	download_fail) echo https://github.com/aaron-kunde/setup-project/blob/master/non-existing.file
	   ;;
	*) echo https://github.com/aaron-kunde/setup-project/blob/master/README.org
	   ;;
    esac
}

remote_installation_file_exists() {
    curl -sIf $(download_url) >/dev/null
}

download_installation_file() {
    echo "Download installation file" 
    curl $(download_url) -o $(local_installation_file)
}

# Specific implementation needed
install_installation_file() {
    echo "Install installation file"
        case "$TMPL_VERSION" in
	installation_fail) return 1
	   ;;
	*) return 0
	   ;;
    esac
}

# TODO: Really specific?
# Specific implementation needed
install() {
    echo "Install new TMPL: $TMPL_VERSION"

    if ! local_installation_file_exists; then
	echo "Local installation file not found: $(installation_file). Try, download new one"
	if remote_installation_file_exists; then
	    download_installation_file
	else
	    echo "ERROR: No installation file found. Abort"
	    abort
	fi
    fi
    install_installation_file
}

init_global_vars
reset_path_vars
set_vars_from_opts ${@}
export_path_vars

if ! is_installed; then
    install || abort
fi

echo "TMPL installed"

reset_global_vars
