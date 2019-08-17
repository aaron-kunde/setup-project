#!/bin/sh

set -e

default_version=1.8.0_92
default_provider=adoptopenjdk
version=$default_version
provider=$default_provider

print_usage() {
    echo "${0} [-p PROVIDER] [-v VERSION] [-s]"
    echo "  -p PROVIDER Provider for JDK binaries"
    echo "     Possible values are: oracle or adoptopenjdk)"
    echo "     Default: $default_provider"
    echo "  -v VERSION Version of the JDK"
    echo "     Default: $default_version"
    echo "  -i Does not execute a new login shell. This can be used, to import"
    echo "     this script in other scripts"
}

short_version() {
    tmp=${version:2}
    echo ${tmp/.0_/u}
}

export_variables() {
    export JAVA_HOME="$HOME/opt/jdk$version"
    export PATH="$PATH:$JAVA_HOME/bin"
    export ORIGINAL_PATH="${PATH}"
}

check_install_file() {
    filename=${1}
    
    if [ ! -f $filename ]; then
	echo "Please download $(basename $filename) from: "
	echo -e "\nhttps://www.oracle.com/technetwork/java/javase/archive-139210.html"
	exit -1
    fi
}    

install_oracle_jdk() {
    if [ ! -d $JAVA_HOME ]; then
	install_file="$HOME/Downloads/jdk-$(short_version $version)-windows-x64.exe"
	check_install_file $install_file
	
	sdk_src_file="$HOME/Downloads/jdk-$(short_version $version)-linux-x64.tar.gz"
	check_install_file $sdk_src_file
	
	# Installing binaries
	tmp_dir=$(mktemp -d)
	7z -o$tmp_dir x $install_file
	unzip $tmp_dir/tools.zip -d $JAVA_HOME
	rm -rf $tmp_dir
	find $JAVA_HOME -name '*.pack' | while IFS= read filename; do $JAVA_HOME/bin/unpack200.exe -r $filename ${filename::-4}jar; done;
	
	# Adding sources
	tar zvxf $sdk_src_file -C "$HOME/opt" $(basename $JAVA_HOME)/src.zip
    else
	echo "Directory $JAVA_HOME already exists. Skipping installation"
    fi
}

while getopts iv:p: opt; do
    case $opt in
	i) skip_exec_bash=true
	   ;;
	v) version=$OPTARG
	   ;;
	p) provider=$OPTARG
	   ;;
    esac
done

case $provider in
    oracle)
	echo "Install Oracle JDK $version"
	install_oracle_jdk
	;;
    adoptopenjdk)
	echo "Install AdoptOpenJDK $version"
	;;
    *)
	echo "ERROR: Wrong provider"
	print_usage
	exit -1
esac
    
export_variables

if [ ! $skip_exec_bash ]; then
    exec "$BASH" --login -i
fi

