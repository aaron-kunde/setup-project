#!/bin/sh

VERSION=3.6.3
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


M2_HOME="$HOME/opt/apache-maven-$VERSION"

if [ ! -d $M2_HOME ]; then
    install_file="/tmp/apache-maven-$VERSION-bin.tar.gz"

    if [ ! -f $install_file ]; then
	url=http://ftp.halifax.rwth-aachen.de/apache/maven/maven-3/$VERSION/binaries/apache-maven-$VERSION-bin.tar.gz
	curl $url -o $install_file
    fi
    tar zxf $install_file -C "$HOME/opt"
fi

export PATH="$PATH:$M2_HOME/bin"
export ORIGINAL_PATH="${PATH}"

if [ ! $skip_exec_bash ]; then
    exec "$BASH" --login -i
fi
