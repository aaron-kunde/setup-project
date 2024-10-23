#!/bin/sh

lib_dir=$(dirname ${BASH_SOURCE})
test $JAVA_HOME || . $lib_dir/setup-java.sh

version=3.9.8

while getopts v:j: opt; do
    case $opt in
	v) version=$OPTARG
	   ;;
	j) JAVA_HOME=$OPTARG
	   PATH="$PATH:$JAVA_HOME/bin"
	   ;;
    esac
done

M2_HOME="$HOME/opt/apache-maven-$version"

if [ ! -d $M2_HOME ]; then
    install_file="/tmp/apache-maven-$version-bin.tar.gz"

    if [ ! -f $install_file ]; then
	url=https://dlcdn.apache.org/maven/maven-3/$version/binaries/apache-maven-$version-bin.tar.gz
	curl $url -o $install_file
    fi
    tar zxf $install_file -C "$HOME/opt"
fi

export PATH="$PATH:$M2_HOME/bin"
export ORIGINAL_PATH="${PATH}"
