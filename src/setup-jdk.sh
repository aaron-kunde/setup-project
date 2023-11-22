init_global_vars() {
    DEFAULT_VERSION=21.0.1+12
    VERSION=$DEFAULT_VERSION
    INSTALLATION_BASE_DIR=$HOME/opt
    # Reset OPTIND, if getopts was used before
    OPTIND=1
}

# Specific implementation needed
print_usage() {
    cat <<EOM
${0} [-v VERSION]
     -v VERSION Version of JDK to install.
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

major_version() {
    local ret=$(echo $VERSION | sed -ne "s/^\([0-9]\+\).*/\1/p")

    if [ -z $ret ]; then
	echo -1
    else
	echo $ret
    fi 
}

# Specific implementation needed
installation_path() {
    local major_version=$(major_version)

    if [ $major_version -gt 8 ]; then
	installation_subdir="$HOME/opt/jdk-$VERSION"
    else
	installation_subdir="$HOME/opt/jdk$VERSION"
    fi

    # There might be different installation paths, depending on target OS
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo $INSTALLATION_BASE_DIR/$installation_subdir
	    ;;
	*)
	    echo $INSTALLATION_BASE_DIR/$installation_subdir
	    ;;
    esac
}

# TODO: Rename to export_vars?
# Specific implementation needed
export_path_vars() {
    echo "Adding $(installation_path) to PATH"
    SETUP_JDK_ORIGINAL_PATH="${PATH}"
    SETUP_JDK_ORIGINAL_JAVA_HOME="{JAVA_HOME}"
    
    export JAVA_HOME=$(installation_path)
    export PATH="$PATH:$JAVA_HOME/bin"
}

# TODO: Rename to reset_vars?
# Specific implementation needed
reset_path_vars() {
    if [ -v SETUP_JDK_ORIGINAL_PATH ]; then
	export PATH="${SETUP_JDK_ORIGINAL_PATH}"
	unset SETUP_JDK_ORIGINAL_PATH
    fi
    if [ -v SETUP_JDK_ORIGINAL_JAVA_HOME ]; then
	export PATH="${SETUP_JDK_ORIGINAL_JAVA_HOME}"
	unset SETUP_JDK_ORIGINAL_JAVA_HOME
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
    java -version 2>/dev/null &&
	(java -version 2>&1 | grep $VERSION)
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
    local major_version=
    echo https://github.com/adoptium/temurin$major_version-binaries/releases/tag/jdk-$VERSION
    case "$VERSION" in
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
        case "$VERSION" in
	installation_fail) return 1
	   ;;
	*) return 0
	   ;;
    esac
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

echo "JDK installed"

reset_global_vars