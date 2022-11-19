#!/bin/sh

NODEJS_VERSION=v14.15.4

print_usage() {
    echo "${0} [-v VERSION]"
    echo "  -v VERSION Version of Node.js"
    echo "     Default: $DEFAULT_NODEJS_VERSION"
}

cleanup_vars() {
    unset DEFAULT_NODEJS_VERSION
    OPTIND=1

    if [ -v SETUP_NODEJS_ORIGINAL_PATH ]; then
       export PATH=$SETUP_NODEJS_ORIGINAL_PATH
       unset SETUP_NODEJS_ORIGINAL_PATH
    fi
}

abort() {
    cleanup_vars
    return -1
}
    
install_dir() {
    echo $HOME/opt/node-$NODEJS_VERSION-win-x64
}

is_installed() {
    node --version 2>/dev/null &&
	(node --version 2>&1 | grep $NODEJS_VERSION)
}

download_url() {
    echo https://nodejs.org/dist/$NODEJS_VERSION/node-$NODEJS_VERSION-win-x64.zip
}

trgt_installation_file() {
    echo /tmp/node-$NODEJS_VERSION-win-x64.zip
}

file_exists_local() {
    local installation_file=${1}
    test -f $(trgt_installation_file ${installation_file})
}

file_exists_remote() {
    local installation_file=${1}
    curl -sIf $(download_url ${installation_file}) >/dev/null
}

download_file() {
    local installation_file=${1}
    curl $(download_url ${installation_file}) -o $(trgt_installation_file ${installation_file})
}

install_nodejs() {
    echo "Install new Node.js version: $NODEJS_VERSION"
    local installation_file=node-$NODEJS_VERSION-win-x64.zip

    if ! file_exists_local $installation_file; then
	echo "Installation file $installation_file not found local. Fetching new one"
	if file_exists_remote $installation_file; then
	    download_file $installation_file
	else
	    echo "ERROR: No installation file found. Abort"
	    abort
	fi
    else
	unzip $(trgt_installation_file) -d $HOME/opt
    fi
}

export_variables() {
    echo "Adding Node.js installation $(install_dir) to PATH"
    export PATH=$PATH:$(install_dir)
    
    SETUP_NODEJS_ORIGINAL_PATH="${PATH}"
}

while getopts v: opt; do
    case $opt in
	v) NODEJS_VERSION=$OPTARG
	   ;;
    esac
done

export_variables
if is_installed $NODEJS_VERSION; then
    echo "Node.js already installed"
else
    echo "Node.js not configured"
    install_nodejs
fi
node -v
cleanup_vars
