-init_global_vars() {
    DEFAULT_VERSION=v14.15.4
    VERSION=$DEFAULT_VERSION
    INSTALLATION_BASE_DIR=$HOME/opt
    OPTIND=1
}

print_usage() {
    cat <<EOM
${0} [-v VERSION]
     -v VERSION Version of Node.js.
     	Default: $DEFAULT_VERSION
EOM
}

-set_vars_from_opts() {
    while getopts v: opt; do
	case $opt in
	    v) VERSION=$OPTARG
	       ;;
	esac
    done
}

-installation_path() {
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo $INSTALLATION_BASE_DIR/node-$VERSION-win-x64
	    ;;
	*)
	    echo $INSTALLATION_BASE_DIR/node-$VERSION-linux-x64/bin
	    ;;
    esac
}

-export_path_vars() {
    echo "Adding $(installation_path) to PATH"
    SETUP_NODEJS_ORIGINAL_PATH="${PATH}"

    export PATH="$(installation_path):${PATH}"
}

-reset_path_vars() {
    if [ -v SETUP_NODEJS_ORIGINAL_PATH ]; then
       export PATH="${SETUP_NODEJS_ORIGINAL_PATH}"
       unset SETUP_NODEJS_ORIGINAL_PATH
    fi
}

-reset_global_vars() {
    unset DEFAULT_VERSION
    unset VERSION
    unset INSTALLATION_BASE_DIR
    OPTIND=1
}

abort() {
    reset_path_vars
    reset_global_vars

    return 0
}


-is_installed() {
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

local_installation_file() {
    echo /tmp/$(installation_file)
}

local_installation_file_exists() {
    test -f $(local_installation_file)
}

download_url() {
    echo https://nodejs.org/dist/$VERSION/$(installation_file)
}

remote_installation_file_exists() {
    curl -sIf $(download_url) >/dev/null
}

download_installation_file() {
    echo "Download installation file" 
    curl $(download_url) -o $(local_installation_file)
}

installation_dir() {
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo $INSTALLATION_BASE_DIR/node-$VERSION-win-x64
	    ;;
	*)
	    echo $INSTALLATION_BASE_DIR/node-$VERSION-linux-x64
	    ;;
    esac
}

install_installation_file() {
    local trgt_dir=$(dirname $(installation_dir))

    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    unzip -q $(local_installation_file) -d $trgt_dir 
	    ;;
	*)
	    tar Jxf $(local_installation_file) -C $trgt_dir
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

node -v

reset_global_vars
