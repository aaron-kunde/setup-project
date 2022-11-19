#!/bin/sh

VERSION=v14.15.4

print_usage() {
    echo "${0} [-v VERSION]"
    echo "  -v VERSION Version of Node.js"
    echo "     Default: $default_version"
}

install_dir() {
    echo $HOME/opt/node-$VERSION-win-x64
}

is_installed() {
    node --version 2>/dev/null &&
	(node --version 2>&1 | grep $VERSION)
}

download_url() {
    echo https://nodejs.org/dist/$VERSION/node-$VERSION-win-x64.zip
}

trgt_installation_file() {
    echo $HOME/Downloads/node-$VERSION-win-x64.zip
}

file_exists_local() {
    test -f $(trgt_installation_file ${1})
}

file_exists_remote() {
    curl -sIf $(download_url ${1}) >/dev/null
}

download_file() {
    curl $(download_url ${1}) -o $(trgt_installation_file ${1})
}
    
install_nodejs() {
    echo "Install new Node.js version: $VERSION"
    installation_file=node-$VERSION-win-x64.zip

    if ! file_exists_local $installation_file; then
	echo "Installation file $installation_file not found local. Fetching new one"
	if file_exists_remote $installation_file; then
	    download_file $installation_file
	else
	    echo "ERROR: No installation file found. Abort"
	    exit -1
	fi
    else
	unzip $(trgt_installation_file) -d $HOME/opt
    fi
}

export_variables() {
   echo "Adding Node.js installation $(install_dir) to PATH"
   export PATH=$PATH:$(install_dir)

   export ORIGINAL_PATH="${PATH}"
}

install_and_setup() {
    if [ ! -d $(install_dir) ]; then
	echo "No Node.js installation found."
	install_nodejs
    fi
    export_variables
}

while getopts v: opt; do
    case $opt in
	v) VERSION=$OPTARG
	   ;;
    esac
done

if is_installed; then
    echo "Node.js already installed"
else
    echo "Node.js not configured"
    install_and_setup
    node -v
fi
