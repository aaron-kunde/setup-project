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

# Specific implementation
installation_path() {
    local major_version=$(major_version)

    if [ $major_version -gt 8 ]; then
	echo $INSTALLATION_BASE_DIR/jdk-$VERSION
    else
	echo $INSTALLATION_BASE_DIR/jdk$VERSION
    fi
}

# TODO: Rename to export_vars?
# Specific implementation
export_path_vars() {
    echo "Adding $(installation_path) to PATH"
    SETUP_JDK_ORIGINAL_PATH="${PATH}"
    SETUP_JDK_ORIGINAL_JAVA_HOME="${JAVA_HOME}"
    
    export JAVA_HOME=$(installation_path)
    export PATH="$JAVA_HOME/bin:${PATH}"
}

# TODO: Rename to reset_vars?
# Specific implementation
reset_path_vars() {
    if [ -v SETUP_JDK_ORIGINAL_PATH ]; then
	export PATH="${SETUP_JDK_ORIGINAL_PATH}"
	unset SETUP_JDK_ORIGINAL_PATH
    fi
    if [ -v SETUP_JDK_ORIGINAL_JAVA_HOME ]; then
	export JAVA_HOME="${SETUP_JDK_ORIGINAL_JAVA_HOME}"
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

# Specific implementation
is_installed() {
    java -version 2>/dev/null &&
	(java -version 2>&1 | grep $VERSION)
}

short_version() {
    local major_version=$(major_version)

    if [ $major_version -gt 8 ]; then
	echo $VERSION | tr '+' '_'
    else
	echo $VERSION | tr -d '-'
    fi
}

# Specific implementation
installation_file() {
    local major_version=$(major_version)
    local short_version=$(short_version)

    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo OpenJDK${major_version}U-jdk_x64_windows_hotspot_$short_version.zip
	    ;;
	*)
	    echo OpenJDK${major_version}U-jdk_x64_linux_hotspot_$short_version.tar.gz
	    ;;
    esac
}

local_installation_file() {
    echo /tmp/$(installation_file)
}

local_installation_file_exists() {
    test -f $(local_installation_file)
}

# Specifc implermentation
download_url() {
    local major_version=$(major_version)
    local base_url=https://github.com/adoptium/temurin$major_version-binaries/releases/download
    local installation_file=$(installation_file)
    
    if [ $major_version -gt 8 ]; then
	echo $base_url/jdk-${VERSION}/$installation_file
    else
	echo $base_url/jdk${VERSION}/$installation_file
    fi
}

remote_installation_file_exists() {    
    curl -sIf $(download_url) >/dev/null
}

download_installation_file() {
    echo "Download installation file" 
    curl -L $(download_url) -o $(local_installation_file)
}

# Specific implementation
install_binaries() {
    echo "Install installation binaries"

    local local_installation_file=$(local_installation_file)
    mkdir -p $JAVA_HOME
    
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    unzip $local_installation_file -d $(dirname $JAVA_HOME)
	    ;;
	*)
	    tar zxf $local_installation_file -C $(dirname $JAVA_HOME)
	    ;;
    esac
}

# Specific implmenetation
check_installation_file() {
    echo "Check installation file"

    local installation_file=$(installation_file)
    local local_installation_sha256_file=/tmp/$installation_file.sha256

    if [ ! -f $local_installation_sha256_file ]; then
	curl -L $(download_url).sha256.txt \
	     -o $local_installation_sha256_file
    fi
    local pwd=$PWD
    cd /tmp
    sha256sum -c $local_installation_sha256_file
    cd $pwd
}

# Specific implementation
install_installation_file() {
    echo "Install installation file"

    check_installation_file
    install_binaries
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
