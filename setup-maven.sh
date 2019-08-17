#!/bin/sh

MVN_VERSION=3.5.4
. $HOME/bin/setup-java.sh -s
# logout
# echo "Moin"
# #JAVA_HOME="$HOME/opt/jdk-8u92-windows-x64"

while getopts sv:j: opt; do
    case $opt in
	s) do_exec_bash=false
	   ;;
	v) MVN_VERSION=$OPTARG
	   ;;
	j) JAVA_HOME=$OPTARG
	   PATH="$PATH:$JAVA_HOME/bin"
	   ;;
    esac
done


M2_HOME="$HOME/opt/apache-maven-$MVN_VERSION"

if [ ! -d $M2_HOME ]; then
    install_file="$HOME/Downloads/apache-maven-$MVN_VERSION-bin.tar.gz"

    if [ ! -f $install_file ]; then
	url=http://ftp.halifax.rwth-aachen.de/apache/maven/maven-3/$MVN_VERSION/binaries/apache-maven-$MVN_VERSION-bin.tar.gz
	curl $url -o $install_file
    fi
    tar zxf $install_file -C "$HOME/opt"
fi

export PATH="$PATH:$M2_HOME/bin"
export ORIGINAL_PATH="${PATH}"

exec "$BASH" --login -i
