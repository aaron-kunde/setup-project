init_global_vars() {
    DEFAULT_VERSION=8.4
    VERSION=$DEFAULT_VERSION
    INSTALLATION_BASE_DIR=$HOME/opt
    # Reset OPTIND, if getopts was used before
    OPTIND=1
}

# Specific implementation needed
print_usage() {
    cat <<EOM
${0} [-v VERSION]
     -v VERSION Version of GRADLE to install.
     	Default: $DEFAULT_VERSION
EOM
}

# Specific implementation needed
set_vars_from_opts() {
    while getopts v: opt; do
	case $opt in
	    v) VERSION=$OPTARG
	       ;;
	esac
    done
}

# Specific implementation
installation_path() {
    echo $INSTALLATION_BASE_DIR/gradle-$VERSION
}

# TODO: Rename to export_vars?
# Specific implementation
export_path_vars() {
    echo "Adding $(installation_path) to PATH"
    SETUP_GRADLE_ORIGINAL_PATH="${PATH}"
    SETUP_GRADLE_ORIGINAL_GRADLE_HOME=${GRADLE_HOME}

    export GRADLE_HOME="$(installation_path)"
    export PATH="$GRADLE_HOME/bin:${PATH}"
}

# TODO: Rename to reset_vars?
# Specific implementation
reset_path_vars() {
    if [ -v SETUP_GRADLE_ORIGINAL_PATH ]; then
	export PATH="${SETUP_GRADLE_ORIGINAL_PATH}"
	unset SETUP_GRADLE_ORIGINAL_PATH
    fi
    if [ -v SETUP_GRADLE_ORIGINAL_GRADLE_HOME ]; then
	export GRADLE_HOME="${SETUP_GRADLE_ORIGINAL_GRADLE_HOME}"
	unset SETUP_GRADLE_ORIGINAL_GRADLE_HOME
    fi
}

reset_global_vars() {
    unset DEFAULT_VERSION
    unset VERSION
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
    case "$VERSION" in
	installed) return 0
	    ;;
	*) return 1
	    ;;
    esac
}

# Specific implementation
installation_file() {
    echo gradle-$VERSION-bin.zip
}

local_installation_file() {
    echo /tmp/$(installation_file)
}

local_installation_file_exists() {
    test -f $(local_installation_file)
}

# Specifc implermentation
download_url() {
    echo https://services.gradle.org/distributions/$(installation_file)
}

remote_installation_file_exists() {
    curl -sIf $(download_url) >/dev/null
}

download_installation_file() {
    echo "Download installation file" 
    curl -L $(download_url) -o $(local_installation_file)
}

# Specific implementation
install_installation_file() {
    echo "Install installation file"
    unzip $(local_installation_file) -d $(dirname $GRADLE_HOME)
}

install() {
    echo "Install version: $VERSION"

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

echo "Gradle installed"

reset_global_vars
