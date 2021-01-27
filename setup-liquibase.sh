#!/bin/sh

VERSION=3.8.9
test $JAVA_HOME || . $HOME/bin/setup-java.sh -i

while getopts isv:j: opt; do
    case $opt in
	i) skip_exec_bash=true
	   ;;
	s) do_exec_bash=false
	   ;;
	v) VERSION=$OPTARG
	   ;;
	j) JAVA_HOME=$OPTARG
	   PATH="$PATH:$JAVA_HOME/bin"
	   ;;
    esac
done


LIQUIBASE_HOME="$HOME/opt/liquibase-$VERSION"

if [ ! -d $LIQUIBASE_HOME ]; then
    install_file="/tmp/liquibase-$VERSION.tar.gz"

    if [ ! -f $install_file ]; then
	url=https://github.com/liquibase/liquibase/releases/download/v$VERSION/liquibase-$VERSION.tar.gz
	curl $url -o $install_file
    fi
    tar zxf $install_file -C "$HOME/opt"
fi

export PATH="$PATH:$LIQUIBASE_HOME"
export ORIGINAL_PATH="${PATH}"

if [ ! $skip_exec_bash ]; then
    exec "$BASH" --login -i
fi
