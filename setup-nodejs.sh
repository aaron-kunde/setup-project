#!/bin/sh

init() {
    DEFAULT_NODEJS_VERSION=v14.15.4
    NODEJS_VERSION=$DEFAULT_NODEJS_VERSION
    OPTIND=1
    INSTALLATION_BASE_DIR=$HOME/opt
}

print_usage() {
    cat <<EOM
${0} [-v VERSION]
     -v VERSION Version of Node.js.
     	Default: $DEFAULT_NODEJS_VERSION
EOM
}

set_vars_from_opts() {
    while getopts v: opt; do
	case $opt in
	    v) NODEJS_VERSION=$OPTARG
	       ;;
	esac
    done
}

installation_path() {
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo $INSTALLATION_BASE_DIR/node-$NODEJS_VERSION-win-x64
	    ;;
	*)
	    echo $INSTALLATION_BASE_DIR/node-$NODEJS_VERSION-linux-x64/bin
	    ;;
    esac
}

export_path_vars() {
    echo "Adding $(installation_path) to PATH"
    SETUP_NODEJS_ORIGINAL_PATH="${PATH}"

    export PATH="$(installation_path):${PATH}"
}

reset_path_vars() {
    if [ -v SETUP_NODEJS_ORIGINAL_PATH ]; then
       export PATH="${SETUP_NODEJS_ORIGINAL_PATH}"
       unset SETUP_NODEJS_ORIGINAL_PATH
    fi
}

reset_global_vars() {
    unset DEFAULT_NODEJS_VERSION
    unset NODEJS_VERSION
    unset INSTALLATION_BASE_DIR
    OPTIND=1
}

abort() {
    reset_path_vars
    reset_global_vars

    return -1
}

installation_dir() {
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo $INSTALLATION_BASE_DIR/node-$NODEJS_VERSION-win-x64
	    ;;
	*)
	    echo $INSTALLATION_BASE_DIR/node-$NODEJS_VERSION-linux-x64
	    ;;
    esac
}


is_installed() {
    node --version 2>/dev/null &&
	(node --version 2>&1 | grep $NODEJS_VERSION)
}

download_url() {
    echo https://nodejs.org/dist/$NODEJS_VERSION/$(installation_file)
}

local_installation_file() {
    echo /tmp/$(installation_file)
}

file_exists_local() {
    test -f $(local_installation_file)
}

file_exists_remote() {
    curl -sIf $(download_url) >/dev/null
}

download_file() {
    curl $(download_url) -o $(local_installation_file)
}

installation_file() {
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo node-$NODEJS_VERSION-win-x64.zip
	    ;;
	*)
	    echo node-$NODEJS_VERSION-linux-x64.tar.xz
	    ;;
    esac
}

extract_installation_file() {
    local trgt_dir=$(dirname $(installation_dir))

    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    unzip $(local_installation_file) -d $trgt_dir 
	    ;;
	*)
	    tar Jxf $(local_installation_file) -C $trgt_dir
	    ;;
    esac
}

install_nodejs() {
    echo "Install new Node.js version: $NODEJS_VERSION"

    if ! file_exists_local; then
	echo "Installation file $(installation_file) not found local. Fetching new one"
	if file_exists_remote; then
	    download_file
	else
	    echo "ERROR: No installation file found. Abort"
	    abort
	fi
    else
	extract_installation_file
    fi
}


init
reset_path_vars
set_vars_from_opts ${@}
export_path_vars

if is_installed; then
    echo "Node.js already installed"
else
    echo "Node.js not configured"
    install_nodejs
fi
node -v
reset_global_vars
