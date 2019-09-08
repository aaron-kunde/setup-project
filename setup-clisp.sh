#!/bin/sh

VERSION=2.49

while getopts sv: opt; do
    case $opt in
	s) do_exec_bash=false
	   ;;
	v) VERSION=$OPTARG
	   ;;
    esac
done


CLISP_HOME="$HOME/opt/clisp-$VERSION"

if [ ! -d $CLISP_HOME ]; then
    install_file="$HOME/Downloads/clisp-$VERSION-win32-mingw-big.zip"

    if [ ! -f $install_file ]; then
	url=https://iweb.dl.sourceforge.net/project/clisp/clisp/$VERSION/clisp-$VERSION-win32-mingw-big.zip

	curl $url -o $install_file
    fi
    unzip $install_file -d "$HOME/opt"
fi

export PATH="$PATH:$CLISP_HOME"
export ORIGINAL_PATH="${PATH}"

exec "$BASH" --login -i
