#!/bin/sh

VERSION=5.6.2
test $JAVA_HOME || . $HOME/bin/setup-java.sh -i

while getopts sv:j: opt; do
    case $opt in
	s) do_exec_bash=false
	   ;;
	v) VERSION=$OPTARG
	   ;;
	j) JAVA_HOME=$OPTARG
	   PATH="$PATH:$JAVA_HOME/bin"
	   ;;
    esac
done


GRADLE_HOME="$HOME/opt/gradle-$VERSION"

if [ ! -d $GRADLE_HOME ]; then
    install_file="$HOME/Downloads/gradle-$VERSION-bin.zip"

    if [ ! -f $install_file ]; then
	url=https://services.gradle.org/distributions/gradle-$VERSION-bin.zip
	curl -L $url -o $install_file
    fi
    unzip -d "$HOME/opt" "$install_file"
fi

export PATH="$PATH:$GRADLE_HOME/bin"
export ORIGINAL_PATH="${PATH}"

exec "$BASH" --login -i
